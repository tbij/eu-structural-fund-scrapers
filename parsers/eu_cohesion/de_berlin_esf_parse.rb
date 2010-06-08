require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBerlinEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  def parse resource
    formats = [:string, :string, /^\d\d\.\d\d\.\d\d\d\d$/, /^(((\d|\.)*\,\d\d)|)$/, /^(((\d|\.)*\,\d\d)|0|)$/]
    groups = get_text_groups(resource, formats, 'text[@font="1"]')
    @projects = []

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 5
        raise by_position.keys.inspect + ': ' + group.inspect + ' -> ' + by_position.to_yaml
      end
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_berlin_esf.csv'
  end

  def add_project by_position, resource
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip
      unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/] && !value[/Deutsch als Fremdsprache/]
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
    :begunstigter,
    :projekt,
    :datum_erstbewilligung,
    :bewilligung_offentlicher_mittel,
    :gesamtauszahlungsbetrag_abgeschlossener_projekte,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def first_data_value
    'a & d Schulungszentrum GmbH'
  end

  def split_this text
    case text
    when /^(.*Verbraucherschutz)(Freiwilliges.*)$/
      [$1,$2]
    when /^(.*Integration mbH)(MmB.*)$/
      [$1,$2]
    when /^(.*\(MAE\)) (03.06.2008)$/
      [$1,$2]
    when /^(.*Multiplikatoren) (01.09.2008)$/
      [$1,$2]
    else
      nil
    end
  end
# 
  # def ignore_this
    # {
# 'Filter: ESF' => true,
# 'Datenquelle: Indikativer Finanzplan ESF / VERA' => true,
# 'Stand der Daten: 15 Jan 2010 06:33:56' => true,
# 'Alle Angaben in Euro' => true
    # }
  # end
  
end
