require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItValleDaosteEfreParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('It scrape')
    resources = result.scraped_resources
    @projects = []
    # EFRE
    resource = resources.detect {|r| r.uri == 'http://www.regione.vda.it/gestione/gestione_contenuti/allegato.asp?pk_allegato=2974'}
    @first_data_value = 'I'
    parse resource, '5'

    # EFRE/ Technical assistance
    # resource = resources.detect {|r| r.web_resource.uri == 'http://www.regione.vda.it/gestione/gestione_contenuti/allegato.asp?pk_allegato=7600'}
    # @first_data_value = 'Schleich GmbH'
    # parse resource, '0'

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_valle_daoste_efre.csv'
  end

  def parse resource, font_number
    formats = [:string, /.+/, /^\d\d\d\d$/, /^(\d|\.)*\,\d\d$/]
    groups = get_text_groups(resource, formats, 'text[@font="'+font_number+'"]')

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 6
        log_by_position by_position, group
      end
      add_project(by_position, resource)
    end
  end

  def add_project by_position, resource
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip
      unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/]
      end
      project.morph(attribute_keys[index], value)
    end
    project.fund_type = 'EFRE'
    project.currency = 'EUR'
    project.uri = resource.uri
    @projects << project
  end

  def attribute_keys
    [
    :asse,
    :attivita,
    :operazione,
    :nome_del_beneficiario,
    :anno_di_assegnazione,
    :importo_pubblico_totale_assegnato,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def first_data_value
    @first_data_value
  end

  # def split_this text
    # case text
      # when /^(.+)(Förderprogramm für zusätzliche Ausbildungsplätze)$/
        # [$1,'Förderprogramm für zusätzliche Ausbildungsplätze']
      # else
        # nil
    # end
  # end
# 
  # def ignore_this
    # [
      # 'VERZEICHNIS DER BEGÜNSTIGTEN FÜR BADEN-WÜRTTEMBERG 2008',
      # 'Auszahlung von öffentlichen Mitteln an die Begünstigten',
      # 'Name des Begünstigten',
      # 'Bezeichnung des Vorhabens',
      # 'Jahr der',
      # 'Bewilligung /',
      # 'Restzahlung',
      # 'Gewährte',
      # 'Bei Abschluss des',
      # 'Vorhabens gezahlte',
      # 'Gesamtbeträge',
      # 'Vorhaben'
      # ].inject({}) {|h,x| h[x] = true; h}
  # end
  
end
