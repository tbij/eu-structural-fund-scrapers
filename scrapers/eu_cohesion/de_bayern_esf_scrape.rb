require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBayernEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    uri = 'http://www.stmas.bayern.de/arbeit/esf2007-2013/inf-beguenstigte-2008.pdf'
    WebResource.scrape_and_add(uri, result)
  end
end
