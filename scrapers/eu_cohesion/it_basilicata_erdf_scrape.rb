require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItBasilicataErdfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://localhost:9999/DOCUMENT_FILE_100421.pdf', result, :is_pdf => true)
  end
end
