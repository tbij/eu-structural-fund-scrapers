require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBremenScrape
  include EuCohesion::ScraperBase
  def perform result
    [
    'http://www.efre-bremen.de/sixcms/media.php/13/BEGUENSTIGTENVERZEICHNIS%202009-12.pdf',
    'http://www.esf-bremen.de/sixcms/media.php/13/reportS0602-0-0-36-100115.pdf',
    ].each do |uri|
        WebResource.scrape_and_add(uri, result)
    end    
  end
end
