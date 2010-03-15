require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBrandenburgScrape
  include EuCohesion::ScraperBase
  def perform result
    [
    'http://www.mwe.brandenburg.de/sixcms/media.php/gsid=lbm1.a.1312.de/Verzeich.pdf',
    ].each do |uri|
        WebResource.scrape_and_add(uri, result)
    end    
  end
end
