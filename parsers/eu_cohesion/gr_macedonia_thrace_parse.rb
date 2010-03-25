require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::GrMacedoniaThraceParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Gr scrape')
    resources = result.scraped_resources
    uri = 'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=343'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    lines = resource.contents.split("\n")
    # print_histogram lines
    handle_lines(lines, uri)
    @projects.pop
    write_csv attribute_keys, attribute_keys, csv_name
  end

  def csv_name
    'eu_cohesion/gr_macedonia_thrace.csv'
  end

  def bounds
    [[0,24],[25,94],[95,99],[116,170],176]
  end
  
  def first_value
    'Νοµαρχιακή Αυτοδιοίκηση'
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
