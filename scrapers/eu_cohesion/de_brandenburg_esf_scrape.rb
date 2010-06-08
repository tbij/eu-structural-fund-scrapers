require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBrandenburgEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    options = {:is_pdf => true}
    WebResource.scrape_and_add('http://www.esf.brandenburg.de/sixcms/media.php/land_bb_boa_01.c.154782.de', result, options)
  end
end
