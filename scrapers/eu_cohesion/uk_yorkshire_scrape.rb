require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkYorkshireScrape
  include EuCohesion::ScraperBase
  def uri
    "http://www.yorkshire-forward.com/sites/default/files/documents/Beneficiary%20List%2018-01-10.pdf"
  end
end
