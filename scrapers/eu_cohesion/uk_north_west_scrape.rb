require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkNorthWestScrape
  include EuCohesion::ScraperBase
  def uri
    "http://www.erdfnw.co.uk/about-us/programme-beneficiaries"
  end
end
