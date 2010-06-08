require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItBolzanoBozenEsf1Scrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://www.provinz.bz.it/europa/esf/download/Elenco_beneficiari_FSE_20091806.pdf', result, :is_pdf => true)
  end
end
