require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::EsEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    [
    'http://ec.europa.eu/employment_social/esf/docs/beneficiarios_2007-_fse-espana1.pdf',
    ].each do |uri|
        WebResource.scrape_and_add(uri, result)
    end    
  end
end
