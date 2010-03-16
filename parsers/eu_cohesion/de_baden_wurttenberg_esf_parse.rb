require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBadenWurttenbergEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources

    @projects = []

    # 2007
    resource = resources.detect {|r| r.web_resource.uri == 'http://www.esf-bw.de/esf/fileadmin/user_upload/downloads/Ministerium_fuer_Arbeit_und_Soziales/Verzeichnis_der_Beguenstigten/ESF_Liste_der_Beguenstigten_2007_sortiert_01.pdf'}
    @first_data_value = '2-Rad-Service Oberstenfeld'
    parse resource, '1'

    # 2008
    resource = resources.detect {|r| r.web_resource.uri == 'http://www.esf-bw.de/esf/fileadmin/user_upload/downloads/Ministerium_fuer_Arbeit_und_Soziales/Verzeichnis_der_Beguenstigten/ESF_BW_Liste_der_Beguenstigten_2008.pdf'}
    @first_data_value = 'Schleich GmbH'
    parse resource, '0'

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_baden_wurttenberg_esf.csv'
  end

  def parse resource, font_number
    formats = [:string, /.+/, /^\d\d\d\d$/, /^(\d|\.)*\,\d\d$/]
    groups = get_text_groups(resource, formats, 'text[@font="'+font_number+'"]')

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 4
        # if by_position[429] && by_position[429].first.value == '/ Akti fü di V h'
          # by_position[372] = (by_position[372] + by_position[429])
          # by_position.delete(429)
        # else
          raise by_position.keys.inspect + ': ' + group.inspect + ' -> ' + by_position.to_yaml
        # end
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
    project.fund_type = 'ESF'
    project.currency = 'EUR'
    project.uri = resource.uri
    @projects << project
  end

  def attribute_keys
    [
    :name_des_begunstigten,
    :bezeichnung_des_vorhabens,
    :jahr_bewilligung,
    :gewahrte_betrage,
    # :bei_abschluss_des_vorhabens_gezahlte_gesamtbetrage,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def first_data_value
    @first_data_value
  end

  def split_this text
    case text.strip
      when /^(.+)(Förderprogramm für zusätzliche Ausbildungsplätze)$/
        [$1,'Förderprogramm für zusätzliche Ausbildungsplätze']
      else
        nil
    end
  end

  def ignore_this
    [
      'VERZEICHNIS DER BEGÜNSTIGTEN FÜR BADEN-WÜRTTEMBERG 2008',
      'Auszahlung von öffentlichen Mitteln an die Begünstigten',
      'Name des Begünstigten',
      'Bezeichnung des Vorhabens',
      'Jahr der',
      'Bewilligung /',
      'Restzahlung',
      'Gewährte',
      'Bei Abschluss des',
      'Vorhabens gezahlte',
      'Gesamtbeträge',
      'Vorhaben'
      ].inject({}) {|h,x| h[x] = true; h}
  end
  
end
