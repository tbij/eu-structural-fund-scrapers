require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::GrWesternGreeceParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Gr scrape')
    resources = result.scraped_resources
    uri = 'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=361'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    text = resource.contents
    lines = text.split("\n")
    # print_histogram lines
    handle_lines(lines, uri)
    @projects.pop
    write_csv attribute_keys, attribute_keys, 'eu_cohesion/gr_western_greece.csv'
  end

  def bounds
    [[0,45],[46,80],[94,99],[107,128],161]
  end
  
  def first_value
    '«Ενέργειες στήριξης ηλικιωµένων ατόµων'
  end

  def attribute_keys
    [
    :payee_name,
    :project_title,
    :year_joined,
    :public_expenditure_listing,
    :fund,
    :uri
    ]
  end

end
