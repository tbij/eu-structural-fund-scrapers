require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::RoApril2010Scrape
  include EuCohesion::ScraperBase
  def perform result
    [
      "http://localhost:9999/Lista_contractate_POR_30_aprilie_2010.pdf",
      "http://localhost:9999/Lista_contractate_POS_CCE_30_aprilie_2010.pdf",
      "http://localhost:9999/Lista_contractate_POS_DRU_30_aprilie_2010.pdf",
      "http://localhost:9999/Lista_contractate_POS_Mediu_30_aprilie_2010.pdf",
      "http://localhost:9999/Lista_contractate_POS_Transport_30_aprilie_2010.pdf",
      "http://localhost:9999/Lista_contractate_PO_AT_30_aprilie_2010.pdf",
      "http://localhost:9999/Lista_contractate_PO_DCA_30_aprilie_2010.pdf"
    ].each do |uri|
      WebResource.scrape_and_add(uri, result, :is_pdf => true)
    end    
  end
end
