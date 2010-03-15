require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkSouthEastParse

  include EuCohesion::ParserBase

  def perform result
    @projects = []
    resources = result.scraped_resources    
    text = resource.first.contents
    uri = resource.uri
    parse text, uri

    write_csv attributes, attribute_keys, 'eu_cohesion/uk_south_east.csv'
  end
  
  def parse text, uri
    fund = nil
    priority = nil
    successful = false
    text.gsub!('£','')
    text.each_line do |line|
      line.strip!
      case line
        when /^(LOWLANDS AND UPLANDS|Decisions on Applications|Project Reference|Organisation Name)/
        when /European Social Fund/
          fund = 'European Social Fund'
        when /European Regional Development Fund/
          fund = 'European Regional Development Fund'
        when /^Priority /
          priority = 'Priority 1: Progressing Into Employment'
        when /Successful /
          successful = true
        when /Unsuccessful /
          successful = false
        else
          if successful
            values = values_from_line(line)
            values.each {|v| v.strip!}
            # y values
            add_project values, fund, priority, uri
          end
      end
    end
  end
 
  def add_project values, fund, priority, uri
    return unless values.size > 2
    project = EuCohesion::Project.new
    project.uri = uri
    project.fund = fund
    project.priority = priority

    if values.size == 3
      project.organisation_name = values[0]
      project.project_title = values[1]
      project.indicative_award = values[2]
    elsif values.size == 4
      if fund == 'European Social Fund'
        project.organisation_name = values[0]
        project.project_title = values[1]
        project.duration_recommended = values[2]
        project.indicative_award = values[3]
      else
        project.project_reference = values[0]
        project.organisation_name = values[1]
        project.project_title = values[2]
        project.indicative_award = values[3]
      end
    elsif values.size == 5
      project.project_reference = values[0]
      project.organisation_name = values[1]
      project.project_title = values[2]
      project.duration_recommended = values[3]
      project.indicative_award = values[4]
    end
    
    @projects << project
  end

  def attributes
    attribute_keys
  end
  
  def attribute_keys
    [
      :organisation_name,
      :project_title,
      :indicative_award,
      :fund,
      :duration_recommended,
      :project_reference,
      :priority,
      :uri
    ]
  end

end
