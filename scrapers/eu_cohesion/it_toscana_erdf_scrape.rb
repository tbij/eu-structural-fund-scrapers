require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItToscanaErdfScrape
  include EuCohesion::ScraperBase
  def perform result
    [
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/cea170afc5b83f34593fc5dc4762cba2_elencobeneficiari11c15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/bcf588c204e36bdad5a9c905353c5695_elencobeneficiari13a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/8fabd83179a45260a3121eef159bdc68_elencobeneficiari13b15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/00e5d3442a34f3e8c0ed1efa63f29d0a_elencobeneficiari14a115022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/1ee39335135d2ea3de6e77e5af362923_elencobeneficiari14b115022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/e5c49386eb7071e17554fb8fd4c8924a_elencobeneficiari14b215022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/71f1720168f8e80522b4cca1a2f7a96b_elencobeneficiari15a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/9fbfbd38f140bc2ece0f236234d790f7_elencobeneficiari15b15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/607db8711c7626a71c715337a927f3d3_elencobeneficiari1615022010.pdf',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92197%7D',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/4db559cf8adc194c39b67698f17a69ae_elencobeneficiari23a15022010.pdf',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92199%7D',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/800c55a82df24aa5c73ef8d3c43c53e1_elencobeneficiari2415022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/b35bef9a3078b26f19aa4eb3c5d2650f_elencobeneficiari2515022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/deb249b65ee0481b31d8611a1b6113be_elencobeneficiari2615022010.pdf',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92204%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92205%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92206%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92207%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92208%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92209%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92210%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92211%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92212%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92213%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92214%7D',
'http://www.regione.toscana.it/creo/beneficiari#%7Bmedia:92215%7D',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/91756043337f1e6232e6dc31b20525ea_elencobeneficiari6115022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/04d0422f173a18625d3088ac3e9e0041_elencobeneficiari6215022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/c75c73b14aed28b4175ad07bbcce6eb0_elencobeneficiari6415022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/71522e4b373e35919a274740b9b93d9f_elencobeneficiari6515022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/4082372c91c98ac349d95e4ea19c07f2_elencobeneficiari6615022010.pdf'
    ].each do |uri|
        puts "scraping #{uri}"
        WebResource.scrape_and_add(uri, result)
    end
  end
end
