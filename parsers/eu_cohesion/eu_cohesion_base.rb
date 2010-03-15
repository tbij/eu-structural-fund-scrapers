require 'pdf/reader'

module EuCohesion
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
end
