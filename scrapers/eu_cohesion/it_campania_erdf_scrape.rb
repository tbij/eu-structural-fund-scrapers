require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItCampaniaErdfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://porfesr.regione.campania.it/opencms/opencms/FESR/download/beneficiari.pdf', result)
  end
end
