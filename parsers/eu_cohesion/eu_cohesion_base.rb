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
    has_string_value?(text) && text.value[@formats[offset]]
  end

  def start_of_data text
    !@started && has_string_value?(text) && (text.value == first_data_value)
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
  
  def get_text_groups resource, formats
    @formats = formats
    @stack = []
    @started = false
    @groups = []
    @pdf_text = resource.contents
    @plain_pdf_text = resource.plain_pdf_contents
    xml = resource.xml_pdf_contents.gsub(" id="," id_attr=")
    doc = Hpricot.XML xml
        
    texts = (doc/'text').collect do |text|
      attributes = text.attributes.to_hash
      text = text.inner_text
      if parts = split_this[text]
        parts.collect { |part| make_cell(attributes, part, parts.index(part)) }
      else
        make_cell(attributes, text, 0)
      end
    end.flatten
    output = FasterCSV.generate do |csv|
      texts.each {|text| csv << text.value }
    end
    File.open('texts.csv','w') {|f| f.write output}
    texts.each {|text| group_text(text) }
    
    output = FasterCSV.generate do |csv|
      @groups.each {|texts| csv << texts.collect(&:value) }
    end
    File.open('groups.csv','w') {|f| f.write output}
    
    @groups.each do |group|
      raise group.inspect if group.select{|x|x.is_a?(Hash)}.size > 0 # check groups not hashes
    end
    @groups
  end
  
  def values_at_position groups, index
    groups.collect{|g| g[index]}.collect(&:value).uniq.collect { |v| v.gsub('+','\+').gsub('(','\(').gsub(')','\)').gsub('[','\[').gsub(']','\]') }
  end

end
