require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItUmbriaErdfScrape
  include EuCohesion::ScraperBase
  def perform result
    [
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/01_Ass1_Pacc_Int_Agevol.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/02_Ass1_Attiv_A1.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/AsseI_attiv_a4_lugl09.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/Beneficiari_1_sem.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/AsseII_attiv_a1_lug09.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/06_Asse2_Attiv_A3.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/AsseIII_attiv_a3_lug09.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/AsseIII_attiv_b3_lug09.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/01_AsseV_attiv1_Assist_Tecn.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/02_AsseV_attiv2_Assist_Tecn.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/03_AsseV_attiv3_Assist_Tecn.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/05_AsseV_attiv5_Assist_Tecn.pdf'
    ].each do |uri|
        puts "scraping #{uri}"
        WebResource.scrape_and_add(uri, result)
    end
  end
end
