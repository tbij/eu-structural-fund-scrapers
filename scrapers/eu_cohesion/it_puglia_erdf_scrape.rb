require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItPugliaErdfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://www.regione.puglia.it/web/packages/progetti/POFESR/documenti/ElencoBeneficiariFESR_Regione_Puglia.pdf', result)
  end
end
