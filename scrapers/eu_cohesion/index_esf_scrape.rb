require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::IndexEsfScrape
  include EuCohesion::ScraperBase
  def uri
    "http://ec.europa.eu/employment_social/esf/xml/esf-map-funded-en.xml"
  end
end
