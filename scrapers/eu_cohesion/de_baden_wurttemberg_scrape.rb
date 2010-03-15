require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBadenWurttembergScrape
  include EuCohesion::ScraperBase
  def perform result
    [
    "http://www.rwb-efre.baden-wuerttemberg.de/doks/Transparenzliste_31-12-2008.pdf",
    'http://www.esf-bw.de/esf/fileadmin/user_upload/downloads/Ministerium_fuer_Arbeit_und_Soziales/Verzeichnis_der_Beguenstigten/ESF_Liste_der_Beguenstigten_2007_sortiert_01.pdf',
    'http://www.esf-bw.de/esf/fileadmin/user_upload/downloads/Ministerium_fuer_Arbeit_und_Soziales/Verzeichnis_der_Beguenstigten/ESF_BW_Liste_der_Beguenstigten_2008.pdf'
    ].each do |uri|
        WebResource.scrape_and_add(uri, result)
    end
  end
end
