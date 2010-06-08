require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItEmiliaRomagnaEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://www.emiliaromagnasapere.it/fse/fondo-sociale-europeo/documentibeneficiari/beneficiari_2008por', result)
  end
end
