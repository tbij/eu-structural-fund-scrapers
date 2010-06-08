require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeNordrheinWestfalenEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    uri = 'http://www.arbeit.nrw.de/pdf/esf/operationelles_programm_beguenstigtenverzeichnis_barr.pdf'
    WebResource.scrape_and_add(uri, result)
  end
end
