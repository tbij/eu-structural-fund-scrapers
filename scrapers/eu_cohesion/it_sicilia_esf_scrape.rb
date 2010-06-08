require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItSiciliaEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    WebResource.scrape_and_add('http://www.sicilia-fse.it/BeneficiariFSE_agg20091231.pdf', result, :is_pdf => true)
  end
end
