require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeHamburgScrape
  include EuCohesion::ScraperBase
  def perform result
    [
    'http://www.hamburg.de/contentblob/1624550/data/efre-beguenstigte.pdf',
    'http://www.esf-hamburg.de/contentblob/1379164/data/liste-gefoerderter-projekte.pdf'
    ].each do |uri|
        WebResource.scrape_and_add(uri, result)
    end    
  end
end
