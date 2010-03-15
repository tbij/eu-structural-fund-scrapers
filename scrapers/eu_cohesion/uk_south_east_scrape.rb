require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkSouthEastScrape
  include EuCohesion::ScraperBase
  def uri
    "http://www.seeda.org.uk/European%5FInitiatives/European%5FSocial%5FFund/Provider_Area/docs/ProjectsList_07-10_ESFSept09.pdf"
  end
end
