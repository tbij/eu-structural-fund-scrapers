require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::GrAtticaParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Gr scrape')
    resources = result.scraped_resources
    uri = 'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=325'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    text = resource.contents
    text.sub!('                            ∆ιάφορες κατασκευές και αναπλάσεις στην περιοχή του Μεγάλου',"\n"+'                            ∆ιάφορες κατασκευές και αναπλάσεις στην περιοχή του Μεγάλου')
    lines = text.split("\n")
    lines = lines.select {|x| !x[/(ΚΑΤΑΛΟΓΟΣ ∆ΙΚΑΙΟΥΧ|2007-2013)/]}
    print_histogram lines
    handle_lines(lines, uri)
    write_csv attribute_keys, attribute_keys, csv_name
  end

  def csv_name
    'eu_cohesion/gr_attica.csv'
  end

  def bounds
    [[0,24],[25,60],[92,99],[111,128],129]
  end
  
  def first_value
    'Νοµαρχία Ανατολικής'
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
