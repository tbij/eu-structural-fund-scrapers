require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkYorkshireParse

  def perform result
    @projects = []
    resources = result.scraped_resources
    text = resources.first.contents
    parse text
    
    puts @projects.last.morph_attributes.keys.inspect
    write_csv
  end
  
  def parse text
    text.each_line do |line|
      case line
        when /^[A-Z]/
          add_project line unless line[/^Last Updated/]
      end
    end
  end

  def attributes
    ["Name of Beneficiary","Name of Operation","Priority","ERDF Contracted",
    'Public / Private Match Contracted',"ERDF Start Date","ERDF End Date",
    "Status","Variation","New ERDF committed","New Public Match Committed",
    "ERDF Variation Start Date","ERDF Variation End Date"]
  end
  
  def attribute_keys
    [
      :name_of_beneficiary,
      :name_of_operation,
      :priority,
      :erdf_contracted,
      :public_private_match_contracted,
      :erdf_start_date,
      :erdf_end_date,
      :status,
      :variation,
      :new_erdf_committed,
      :new_public_match_committed,
      :erdf_variation_start_date,
      :erdf_variation_end_date
    ]
  end
  
  def add_project line
    project = EuCohesion::Project.new
    line.strip!
    line.gsub!(/(\d) /, '\1  ')
    line.gsub!('  ', "\t")
    line.squeeze!("\t")
    values = line.split("\t")
    attributes.each_with_index do |attribute, index|
      project.morph(attribute.sub(' / ',' '), values[index])
    end
    
    @projects << project
  end
  
  def write_csv
    output = FasterCSV.generate do |csv|
      csv << attributes
      @projects.each do |project|
        csv << attribute_keys.collect { |key| project.send(key) }
      end
    end
    GitRepo.write_parsed 'eu_cohesion/uk_yorkshire.csv', output
  end
end
