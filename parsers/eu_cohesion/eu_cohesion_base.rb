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
  def write_csv labels, keys, file
    output = FasterCSV.generate do |csv|
      csv << labels
      @projects.each do |project|
        csv << keys.collect { |key| project.send(key) }
      end
    end
    GitRepo.write_parsed file, output
  end
  
  def values_from_line line
    line.strip!
    line.gsub!('  ', "\t")
    line.squeeze!("\t")
    line.split("\t")
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
        @stack << text unless ignore_this[text.value]
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
    @formats = formats
    @stack = []
    @started = false
    @groups = []
    @pdf_text = resource.contents
    @plain_pdf_text = resource.plain_pdf_contents
    xml = resource.xml_pdf_contents.gsub(" id="," id_attr=")
    xml = yield xml if block
    doc = Hpricot.XML xml
        
    texts = (doc/selector).collect do |text|
      attributes = text.attributes.to_hash
      text = text.inner_text
      if parts = split_this(text)
        parts.collect { |part| make_cell(attributes, part, parts.index(part)) }
      else
        make_cell(attributes, text, 0)
      end
    end.flatten
    write_out_csv('texts.csv') {|csv| texts.each {|t| csv << t.value } }

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
end
