require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItLiguriaEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://localhost:9999/ListaBenCRO2009.pdf', result, :is_pdf => true)
  end
end
