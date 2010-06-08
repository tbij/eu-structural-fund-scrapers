require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItPugliaEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://formazione.regione.puglia.it/index.php?page=documenti&id=122&fs_id=347&opz=downfile', result, :is_pdf => true)
  end
end
