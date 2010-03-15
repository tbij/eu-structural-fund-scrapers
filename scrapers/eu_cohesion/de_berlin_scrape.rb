require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBerlinScrape
  include EuCohesion::ScraperBase
  def perform result
    [
    'http://www.berlin.de/imperia/md/content/senatsverwaltungen/senwaf/struktur/efre/efre2007_2013_beg__nstigtenverzeichnis_31122008.pdf?start&ts=1246726906&file=efre2007_2013_beg__nstigtenverzeichnis_31122008.pdf',
    ].each do |uri|
        WebResource.scrape_and_add(uri, result)
    end    
  end
end
