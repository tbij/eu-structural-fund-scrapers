require 'pdf/reader'

module EuCohesion
end

class EuCohesion::Cell
  include Morph
end

class EuCohesion::Project
  include Morph
end

module EuCohesion::ParserBase
  def write_csv labels, keys, file, fields_to_convert=[]
    output = FasterCSV.generate do |csv|
      csv << labels
      @projects.each do |project|
        csv << keys.collect { |key| project.send(key) }
      end
    end
    unless fields_to_convert.empty?
      output = ScalpelConverter.convert_csv(output, :convert => fields_to_convert)
    end
    GitRepo.write_parsed file, output
  end
  
  def translate
    ScalpelTranslator.translate_csv_file csv_name, :translate => translate_fields, :convert => convert_fields
  end
  
  def translate_fields
    [:payee_name, :project_title, :fund]
  end
  
  def convert_fields
    :public_expenditure_listing
  end

  def values_from_line line
    line.strip!
    line.gsub!('  ', "\t")
    line.squeeze!("\t")
    line.split("\t")
  end

  def result_from_scraper name  
    scraper = Scraper.find_by_name(name)
    scraper.last_scrape_result
  end
  
  def add_project data, attribute_names=attributes, &block
    project = EuCohesion::Project.new
    values = yield data, project
    attribute_names.each_with_index do |attribute, index|
      value = values[index]
      value.strip! if value
      project.morph(attribute.to_s.gsub(' / ',' '), value)
    end
    @projects << project
  end

  def make_cell attributes, text, delta
    cell = EuCohesion::Cell.new
    cell.morph attributes
    cell.morph('value', text)
    if delta > 0
      cell.left = (cell.left.to_i + delta).to_s
    end
    cell
  end
  
  def has_string_value? text
    text && text.respond_to?(:value) && text.value.is_a?(String)
  end

  def format_match offset
    text = @stack[offset]
    has_string_value?(text) && text.value.strip[@formats[offset]]
  end

  def start_of_data text
    !@started && has_string_value?(text) && (text.value.strip == first_data_value)
  end

  def group_text text
    @started = true if start_of_data(text)
    if @started
      if has_string_value?(text)
        @stack << text unless ignore_this[text.value.strip]
      else
        $stderr.write text.inspect
      end
      if format_match(-1) && format_match(-2) && format_match(-3)
        @groups << @stack
        @stack = []
      end
    end
  end

  def write_out_csv name, &block
    output = FasterCSV.generate { |csv| yield csv }
    File.open(name,'w') {|f| f.write output}
  end

  def get_text_groups resource, formats, selector='text', &block
    pdf_text = resource.contents
    plain_pdf_text = resource.plain_pdf_contents
    xml = resource.xml_pdf_contents.gsub(" id="," id_attr=")
    get_text_groups_from pdf_text, plain_pdf_text, xml, formats, selector, &block
  end

  def get_text_groups_from pdf_text, plain_pdf_text, xml, formats, selector='text', &block
    @pdf_text = pdf_text
    @plain_pdf_text = plain_pdf_text
    @formats = formats
    @stack = []
    @started = false
    @groups = []
    xml = yield xml if block
    doc = Hpricot.XML xml

    texts = (doc/selector).collect do |text|
      attributes = text.attributes.to_hash
      text = text.inner_text
      if parts = split_this(text.strip)
        parts.collect { |part| make_cell(attributes, part, parts.index(part)) }
      else
        make_cell(attributes, text, 0)
      end
    end.flatten
    write_out_csv('texts.csv') {|csv| texts.each {|t| csv << t.value if t.value } }

    texts.each {|text| group_text(text) }

    write_out_csv('groups.csv') {|csv| @groups.each {|g| csv << g.collect(&:value) } }

    @groups.each do |group|
      raise group.inspect if group.select{|x|x.is_a?(Hash)}.size > 0 # check groups not hashes
    end
    @groups
  end

  def values_at_position groups, index
    groups.collect{|g| g[index]}.collect(&:value).uniq.collect { |v| v.gsub('+','\+').gsub('(','\(').gsub(')','\)').gsub('[','\[').gsub(']','\]') }
  end

  def by_position groups
    groups.each do |group|
      by_position = group.group_by {|x| x.left.to_i }
      yield group, by_position
    end
  end

  def split_this text
    nil
  end

  def ignore_this
    {
    }
  end
  
  def log_by_position by_position, group
    keys = by_position.keys.inspect
    left_to_value = by_position.keys.collect {|k| "#{k} => #{by_position[k].collect(&:value).join(' ')}"}.join("\n")
    raise "#{keys}\n#{group.collect{|x|x.inspect}.join("\n")}\n#{left_to_value}"
  end

  # NEW APPROACH BELOW

  def print_histogram lines
    results = []
    @start = false
    lines.each do |line|
      line = line.mb_chars      
      @start = true if line.include?(first_value)
      if @start
        if line.blank?
        else
          parts = Parser.values_from_line(line).compact
          items = parts.map { |part| process_part(part, line) }.compact
          results += items
        end
      end
    end
    
    Parser.print_column_histogram(results)
  end

  def handle_lines lines, uri
    rows = []
    groups = []
    @start = false
    @new = true
    lines.each do |line|
      line = line.mb_chars
      @start = true if line.include?(first_value)
      if @start
        if line.strip.blank?
          groups << rows unless rows.empty?
          rows = []
        else
          parts = Parser.values_from_bounds(line,bounds).compact
          items = parts.map { |part| process_part(part, line) }.compact
          rows << items
        end
      end
    end
    groups << rows unless rows.empty?
    entries = groups.collect do |rows|
      columns = perform_split rows
      values = do_join columns
    end
    @projects = []
    entries.each do |values|
      add_project(values, attribute_keys) { |data, project| data + [uri] }
    end    
  end
  
  def process_part part, line
    [line.index(part), part]
  end
  
  def do_join columns
    values = []
    columns.each do |items|
      value = items.collect { |item| item[1] }.join(' ').squeeze(' ').strip
      values << value
    end
    values
  end

  def perform_split rows
    splits = Array.new(bounds.size) { |i| [] }
    rows.each do |row|
      row.each do |cell|
        x = cell[0]
        set = false
        bounds.each_with_index do |bound, index|
          if bound.is_a?(Array) && (x >= bound.first) && (x <= bound.last)
            splits[index] << cell
            set = true
          elsif !bound.is_a?(Array) && x >= bound
            splits[index] << cell
            set = true
          end
        end
        unless set
          raise cell.inspect
        end
      end
    end
    splits
  end

end
