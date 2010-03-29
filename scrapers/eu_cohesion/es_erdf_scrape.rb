require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::EsErdfScrape
  include EuCohesion::ScraperBase
  def perform result
    [
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3027)AN11.pdf',     # P.O. FEDER de Andalucía
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3028)AR11.pdf',     # P.O. FEDER de Aragón
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3031)IC11.pdf',     # P.O. FEDER de Canarias
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(2982)CN10.pdf',     # P.O. FEDER de Cantabria
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3033)CL11.pdf',     # P.O. FEDER de Castilla y León
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3032)CM11.pdf',     # P.O. FEDER de Castilla - La Mancha
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3034)CT11.pdf',     # P.O. FEDER de Cataluña
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3035)CE11.pdf',     # P.O. FEDER de Ceuta
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3042)ME11.pdf',     # P.O. FEDER de Melilla
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3041)MD11.pdf',     # P.O. FEDER de Madrid
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3043)NA11.pdf',     # P.O. FEDER de Navarra
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3038)CV11.pdf',     # P.O. FEDER de la Comunidad Valenciana
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3036)EX11.pdf',     # P.O. FEDER de Extremadura
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3037)GA11.pdf',     # P.O. FEDER de Galicia
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3030)BB11.pdf',     # P.O. FEDER de Baleares
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3040)LR11.pdf',     # P.O. FEDER de La Rioja
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3047)PO_AT11.pdf',  # Programa Operativo Fondo de Cohesión - FEDER
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3046)PO_EC11.pdf',  # Programas Operativos Plurirregionales FEDER
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3045)PO_FT11.pdf',  # Programas Operativos Plurirregionales FEDER
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3048)PO_FCH11.pdf',     # Programa Operativo Fondo de Cohesión - FEDER
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3044)EU11.pdf',     # P.O. FEDER del País Vasco
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3029)AS11.pdf',     # P.O. FEDER de Asturias
'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3039)MU11.pdf'      # P.O. FEDER de la Región de Murcia
    ].each do |uri|
        WebResource.scrape_and_add(uri, result)
    end    
  end
end
