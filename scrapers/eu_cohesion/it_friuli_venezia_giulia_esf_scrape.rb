require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItFriuliVeneziaGiuliaEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://www.regione.fvg.it/rafvg/export/sites/default/RAFVG/AT2/ARG13/allegati/LISTA_DEI_BENEFICIARI.pdf', result)
  end
end
