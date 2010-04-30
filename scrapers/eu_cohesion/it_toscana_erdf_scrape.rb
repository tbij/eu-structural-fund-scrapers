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
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/06d92949dc88d6566779deeb9e779f95_elencobeneficiari2115022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/4db559cf8adc194c39b67698f17a69ae_elencobeneficiari23a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/1930b0c14a7e93fca65d781ea2a920c3_elencobeneficiari23b15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/800c55a82df24aa5c73ef8d3c43c53e1_elencobeneficiari2415022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/b35bef9a3078b26f19aa4eb3c5d2650f_elencobeneficiari2515022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/deb249b65ee0481b31d8611a1b6113be_elencobeneficiari2615022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/7b6721d66bd7d90bfe02bbb51b17cc58_elencobeneficiari41a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/ad2526731ff794a74b42b568929925fe_elencobeneficiari41b15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/f8822650b44d6822721c8fb30e999f63_elencobeneficiari4215022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/126fb28b0dcc3e16e52053182a6fbc0c_elencobeneficiari43a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/d2abb87a649925d7fab3e51c835aead6_elencobeneficiari43b15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/c10b53f2dbffa9e61d30435e190238cc_elencobeneficiari44a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/64e5a9b319d4147b1a1085e695a356f4_elencobeneficiari44b15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/c070b599ed8416ed76c4caa27d7eddde_elencobeneficiari45a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/4a53f1cafdca45cccde5afd1083e5dbc_elencobeneficiari54a15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/559ab23bf03ef5b9fe87927d181d1813_elencobeneficiari54b15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/77e108348ea87a5ef6f50923db16fa44_elencobeneficiari54c15022010.pdf',
'http://www.regione.toscana.it/regione/multimedia/RT/documents/2010/02/18/5008063b47a2d744131e145d07207713_elencobeneficiari55a15022010.pdf',
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
