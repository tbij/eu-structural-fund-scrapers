require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::GrEducationLifelongLearningParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Gr scrape')
    resources = result.scraped_resources
    uri = 'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=347'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    text = resource.contents.mb_chars
    text.gsub!(/^(.+(Εφαρµογή ξενόγλωσσων|Ανάπτυξη εθνικού συστήµατος|Μελέτη ανάπτυξης και βελτίωσης των|Εισαγωγική επιµόρφωση για))/) {|x| "\n" + x}
    lines = text.split("\n")
    # print_histogram lines
    handle_lines(lines, uri)
    @projects.pop
    write_csv attribute_keys, attribute_keys, csv_name
  end

  def csv_name
    'eu_cohesion/gr_education_lifelong_learning.csv'
  end

  def bounds
    [[0,26],[27,69],[70,78],[83,128],145]
  end
  
  def first_value
    'Οργάνωση και υλοποίηση Επιτροπών'
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
