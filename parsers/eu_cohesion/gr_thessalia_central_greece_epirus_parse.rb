require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::GrThessaliaCentralGreeceEpirusParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Gr scrape')
    resources = result.scraped_resources
    uri = 'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=362'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    text = resource.contents
    lines = text.split("\n")
    # print_histogram lines
    handle_lines(lines, uri)
    write_csv attribute_keys, attribute_keys, 'eu_cohesion/gr_thessalia_central_greece_epirus_parse.csv'
  end

  def bounds
    [[0,24],[25,60],[92,99],[105,128],155]
  end
  
  def first_value
    'Βελτίωση - Κατασκευή 1ης Επ.Οδού, Τµήµα από'
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
