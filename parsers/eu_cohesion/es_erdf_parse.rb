require File.expand_path(File.dirname(__FILE__) + '/es_erdf_base.rb')

class EuCohesion::EsErdfParse

  include EuCohesion::EsEdrfBase

  def csv_name
    @csv_name
  end

  def perform result
    result = result_from_scraper('Es erdf scrape')
    resources = result.scraped_resources

    files.each do |set|
      uri = set[0]
      @csv_name = "eu_cohesion/es_#{set[1]}_erdf.csv"
      puts @csv_name
      puts uri
      resource = resources.detect {|r| r.web_resource.uri == uri}
      parse resource, uri
      puts 'parsed'
    end
  end

  def files
[
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3027)AN11.pdf', 'andalucia'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3028)AR11.pdf', 'aragon'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3031)IC11.pdf', 'canarias'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(2982)CN10.pdf', 'cantabria'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3033)CL11.pdf', 'leon'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3032)CM11.pdf', 'la_mancha'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3034)CT11.pdf', 'cataluna'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3035)CE11.pdf', 'ceuta'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3042)ME11.pdf', 'melilla'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3041)MD11.pdf', 'madrid'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3043)NA11.pdf', 'navarra'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3038)CV11.pdf', 'valenciana'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3036)EX11.pdf', 'extremadura'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3037)GA11.pdf', 'galicia'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3030)BB11.pdf', 'baleares'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3040)LR11.pdf', 'la_rioja'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3047)PO_AT11.pdf', 'fondo_de_cohesion1'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3046)PO_EC11.pdf', 'plurirregionales1'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3045)PO_FT11.pdf', 'plurirregionales2'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3048)PO_FCH11.pdf', 'fondo_de_cohesion2'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3044)EU11.pdf', 'pais_vasco'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3029)AS11.pdf', 'asturias'],
['http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3039)MU11.pdf', 'murcia']
]
  end
end
