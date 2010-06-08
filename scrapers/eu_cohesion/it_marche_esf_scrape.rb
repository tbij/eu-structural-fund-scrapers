require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItMarcheEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://www.istruzioneformazionelavoro.marche.it/fse/Lista_beneficiari_31_12_2009.pdf', result)
  end
end
