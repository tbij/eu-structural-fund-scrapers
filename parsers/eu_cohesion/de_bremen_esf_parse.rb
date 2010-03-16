require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBremenEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    resource = resources.detect {|r| r.web_resource.uri == 'http://www.esf-bremen.de/sixcms/media.php/13/reportS0602-0-0-36-100115.pdf'}
    parse resource
  end

  def parse resource
    formats = [:string, :string, /^\d\d\d\d$/, /^\d\d\d\d$/, /^(((\d|\.)*\,\d\d)|)$/]
    groups = get_text_groups(resource, formats, 'text[@font="1"]') do |xml|
      xml.sub!('<text top="211" left="848" width="24" height="12" font="1">2010</text>
<text top="254" left="88" width="153" height="12" font="1">Verbund Bremer Kindergruppen</text>',
'<text top="211" left="848" width="24" height="12" font="1">2010</text>
<text top="211" left="999" width="24" height="12" font="1"></text>
<text top="254" left="88" width="153" height="12" font="1">Verbund Bremer Kindergruppen</text>')
      xml
    end
    @projects = []

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 5
        if by_position[429] && by_position[429].first.value == '/ Akti fü di V h'
          by_position[372] = (by_position[372] + by_position[429])
          by_position.delete(429)
        else
          raise by_position.keys.inspect + ': ' + group.inspect + ' -> ' + by_position.to_yaml
        end
      end
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_bremen_esf.csv'
  end

  def add_project by_position, resource
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip
      unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/] && !value[/TSCHOB/]
      end
      if texts.first.left.to_i > 1000
        project.morph(:bei_abschluss_des_vorhabens_gezahlte_gesamtbetrage, value)
      else
        project.morph(attribute_keys[index], value)
      end
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
    :jahr_projektende,
    :gewahrte_betrage,
    :bei_abschluss_des_vorhabens_gezahlte_gesamtbetrage,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def first_data_value
    'AfJ e.V - Kinder- und Jugendhilfe Bremen'
  end

  def split_this text
    case text
    when /^(.+ GmbH)  (.+)$/
      [$1,$2]
    when /^(.+ GmbH & Co.KG)  (.+)$/
      [$1,$2]
    when /IfW - Institut für Wissenstransfer an der Uni Bremen GmbH Excellenzinitiative/
      ['IfW - Institut für Wissenstransfer an der Uni Bremen GmbH',
        'Excellenzinitiative']
    else
      nil
    end
  end

  def ignore_this
    {
'Filter: ESF' => true,
'Datenquelle: Indikativer Finanzplan ESF / VERA' => true,
'Stand der Daten: 15 Jan 2010 06:33:56' => true,
'Alle Angaben in Euro' => true
    }
  end
  
end
