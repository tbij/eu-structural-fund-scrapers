module EuCohesion
end

class EuCohesion::Project
  include Morph
end

class EuCohesion::UkEastMidlandsParse

  def perform result
    @projects = []
    resources = result.scraped_resources
    text = resources.first.contents
    parse text
    
    write_csv
  end
  
  def parse text
    text.each_line do |line|
      case line
        when /^( )+PA/
          add_project line
      end
    end
  end

  def attributes
    ["Priority", "Project Ref", "Financial Start Date",
      "Financial End Date", "Sponsor","Project Title","Description of Project",
      "ERDF Approved Grant (£)","Public Funding (£)"]
  end
  
  def attribute_keys
    [
    :priority,
    :project_ref, 
    :financial_start_date, 
    :financial_end_date, 
    :sponsor, 
    :project_title, 
    :description_of_project, 
    :erdf_approved_grant_£, 
    :public_funding_£ 
    ]
  end
  
  def add_project line
    project = EuCohesion::Project.new
    line.strip!
    line.gsub!('  ', "\t")
    line.squeeze!("\t")
    values = line.split("\t")
    attributes.each_with_index do |attribute, index|
      project.morph(attribute, values[index])
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
    GitRepo.write_parsed 'eu_cohesion/uk_east_midlands.csv', output
  end
end
