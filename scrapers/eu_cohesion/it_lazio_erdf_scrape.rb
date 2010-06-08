require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItLazioErdfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://localhost:9999/elenco_beneficiari_lazio.pdf', result, :is_pdf => true)
  end
end
