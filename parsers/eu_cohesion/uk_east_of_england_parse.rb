require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkEastOfEnglandParse

  include EuCohesion::ParserBase

  def perform result
    @projects = []
    resources = result.scraped_resources
    
    parse resources.first.plain_pdf_contents

    write_csv attributes, attribute_keys, 'eu_cohesion/uk_east_of_england.csv'
  end

  def clean_text text
    text.gsub!('£','')
    text.gsub!("\f",'')
    text.sub!('Low-Carbon Knowledge Transfer University of Cambridge',
      "Low-Carbon Knowledge Transfer\n\nUniversity of Cambridge")
    text.sub!('EASIER University of Hertfordshire 2009 311,753',
      "EASIER\n\nUniversity of Hertfordshire\n\n2009\n\n311,753")
    text.sub!('Resource Efficiency East Renewables East 2008 599,970',
      "Resource Efficiency East\n\nRenewables East\n\n2008\n\n599,970")
    text.sub!('ERDF Technical Assistance 2007-2010 East of England Development Agency',
      "ERDF Technical Assistance 2007-2010\n\nEast of England Development Agency")
    text.sub!('East (Health Pilot) NHS',
      "East (Health Pilot)\n\nNHS")
  end

  def parse text
    clean_text text 
    lines = text.split("\n").select {|x| !x.blank?}.collect {|x| x.strip}
    
    values = Hash.new {|h,k| h[k] = []}
    priority = nil
    index = 0
    lines.each do |line|
      case line
      when /^EAST OF ENGLAND REGIONAL COMPETITIVENESS AND EMPLOYMENT/
        # ignore
      when /^PRIORITY/
        priority = line
      when /^(Project|Beneficiary|Year of Funding|ERDF Funding|Public Match|Private Match|ERDF paid)\s?/
      else
        values[priority] << line
      end
    end
    
    values.each do |priority, values|
      y priority 
      data = values.in_groups_of(6)
      y data
      add_projects data, priority 
    end
  end
  
  def add_projects data, priority
    data.each do |values|
      project = EuCohesion::Project.new
      project.priority = priority
      project.project = values[0]
      project.beneficiary = values[1]
      project.year = values[2]
      project.erdf_funding = values[3]
      project.public_match_funding = values[4]
      project.private_match_funding = values[5]
      @projects << project
    end
  end

  def attributes
    attribute_keys
  end
  
  def attribute_keys
    [
    :project,
    :beneficiary,
    :year,
    :erdf_funding,
    :public_match_funding,
    :private_match_funding,
    :priority
    ]
  end

end
