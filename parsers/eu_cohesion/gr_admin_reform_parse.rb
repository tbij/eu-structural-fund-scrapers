require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::GrAdminReformParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Gr scrape')
    resources = result.scraped_resources
    uri = 'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=358'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    text = resource.contents.mb_chars
    text.gsub!(/(  200(8|9)  )/) {|x| '     '+x+'        ' }
    lines = text.split("\n")
    lines = lines.select {|x| !x[/(ΕΥ∆ ΕΠ ∆Μ 2007-2013|Μονάδα Α1 "Προγραµµατισµού")/] }
    # print_histogram lines
    handle_lines(lines, uri)
    @projects.pop
    write_csv attribute_keys, attribute_keys, 'eu_cohesion/gr_admin_reform.csv'
  end

  def bounds
    [[0,18],[19,86],[88,100],[105,133],144]
  end
  
  def first_value
    'ΕΥ∆ ΕΠ "∆ιοικητική'
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
