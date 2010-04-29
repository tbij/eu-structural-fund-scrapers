require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItToscanaEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    [
'http://www.rete.toscana.it/sett/orient/fp/ListaProgetti.pdf'
    ].each do |uri|
        puts "scraping #{uri}"
        WebResource.scrape_and_add(uri, result)
    end
  end
end
