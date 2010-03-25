require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::GrHumanResourcesDevelopmentParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Gr scrape')
    resources = result.scraped_resources
    uri = 'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=360'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    text = resource.contents.mb_chars
    text.gsub!(/^(Ε.Υ.∆. Ε.Π.|ΟΡΓΑΝΙΣΜΟΣ ΕΡΓΑΤΙΚΗΣ|ΕΙ∆ΙΚΗ ΥΠΗΡΕΣΙΑ)/) {|x| "\n" + x}
    lines = text.split("\n")
    # print_histogram lines
    handle_lines(lines, uri)
    @projects.pop
    project = @projects.detect { |x| x.project_title == 'Τεχνικός Σύµβουλος για την Υποστήριξη της ΕΥΣΕΚΤ ΕΚΤ'}
    project.project_title = 'Τεχνικός Σύµβουλος για την Υποστήριξη της ΕΥΣΕΚΤ'
    project.fund = 'ΕΚΤ'
    write_csv attribute_keys, attribute_keys, csv_name
  end

  def csv_name
    'eu_cohesion/gr_human_resources_development.csv'
  end

  def bounds
    [[0,26],[27,80],[96,100],[113,128],170]
  end
  
  def first_value
    '∆ιεύθυνση Σχεδιασµού και'
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
