require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBerlinEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    options = {:is_pdf => true}
    uri = 'http://www.berlin.de/imperia/md/content/sen-strukturfonds/esf/beguenstigtenverzeichnis_esf_2008.pdf?start&ts=1248686035&file=beguenstigtenverzeichnis_esf_2008.pdf'
    WebResource.scrape_and_add(uri, result, options)
  end
end
