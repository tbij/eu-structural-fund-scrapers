require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItScrape
  include EuCohesion::ScraperBase
  def perform result
    [
'http://www.regione.vda.it/gestione/gestione_contenuti/allegato.asp?pk_allegato=2974',
'http://www.regione.vda.it/gestione/gestione_contenuti/allegato.asp?pk_allegato=7600',
'http://www.regione.vda.it/gestione/gestione_contenuti/allegato.asp?pk_allegato=7754',
'http://www.regione.vda.it/gestione/gestione_contenuti/allegato.asp?pk_allegato=4002',
'http://www.regione.vda.it/gestione/gestione_contenuti/allegato.asp?pk_allegato=7598',
'http://www.regione.vda.it/gestione/gestione_contenuti/allegato.asp?pk_allegato=7764',
'http://www.regione.lombardia.it/shared/ccurl/924/68/LISTA%20BENEFICIARI%20AL%2025_12_09.pdf',
'http://www.regione.lombardia.it/shared/ccurl/474/850/Elenco%20Beneficiari%202009.pdf',
'http://www.regione.lombardia.it/shared/ccurl/633/922/ELENCO%20BENEFICIARI%202008.pdf',
'http://www.provincia.bz.it/europa/download/lista_beneficiari_12.01.2010.pdf',
'http://www.provincia.bz.it/europa/it/service/news.asp?redas=yes&aktuelles_action=300&aktuelles_image_id=404325',
# 'http://www.fse.provincia.tn.it/Trento_nuova_grafica/Listabeneficiari/index.php',
'http://www.regione.veneto.it/NR/rdonlyres/98376518-3F4D-455E-B3FA-3FF19093BB0B/0/Elenco_beneficiari_31_12_2009.pdf',
'http://www.regione.veneto.it/NR/rdonlyres/51BBAB1C-5EAC-4C26-BF87-EFF81430177B/0/ElencobeneficiariPORFSEAsseVI2007201331122009.pdf',
'http://www.regione.fvg.it/rafvg/export/sites/default/RAFVG/AT11/ARG20/allegati/ELENCO_BENEFICIARI_22-01-2010.pdf',
'http://fesr.regione.emilia-romagna.it/allegati/elenco-beneficiari/elenco-delle-imprese-beneficiarie-asse-1-attivita-i.1.2',
'http://fesr.regione.emilia-romagna.it/allegati/elenco-beneficiari/elelnco-beneficiari-asse-2',
'http://fesr.regione.emilia-romagna.it/allegati/elenco-beneficiari/associazioni-temporanee-asse-2',
'http://fesr.regione.emilia-romagna.it/allegati/elenco-beneficiari/elenco-beneficiari-asse-3',
'http://fesr.regione.emilia-romagna.it/allegati/elenco-beneficiari/elenco-beneficiari-asse-4',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/cea170afc5b83f34593fc5dc4762cba2_elencobeneficiari11c15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/bcf588c204e36bdad5a9c905353c5695_elencobeneficiari13a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/8fabd83179a45260a3121eef159bdc68_elencobeneficiari13b15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/00e5d3442a34f3e8c0ed1efa63f29d0a_elencobeneficiari14a115022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/1ee39335135d2ea3de6e77e5af362923_elencobeneficiari14b115022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/e5c49386eb7071e17554fb8fd4c8924a_elencobeneficiari14b215022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/71f1720168f8e80522b4cca1a2f7a96b_elencobeneficiari15a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/9fbfbd38f140bc2ece0f236234d790f7_elencobeneficiari15b15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/607db8711c7626a71c715337a927f3d3_elencobeneficiari1615022010.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/01_Ass1_Pacc_Int_Agevol.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/02_Ass1_Attiv_A1.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/AsseI_attiv_a4_lugl09.pdf',
'http://www.regione.umbria.it/docup/html/download/fesr/beneficiari/Beneficiari_1_sem.pdf',
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
