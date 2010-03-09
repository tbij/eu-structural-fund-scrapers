require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkEastMidlandsParse

  include EuCohesion::ParserBase

  def perform result
    @projects = []
    resources = result.scraped_resources
    text = resources.first.contents
    parse text

    write_csv attributes, attribute_keys, 'eu_cohesion/uk_east_midlands.csv'
  end
  
  def parse text
    text.each_line do |line|
      case line
        when /^( )+PA/
          add_project(line) {|data, project| values_from_line(data)}
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
  
end
