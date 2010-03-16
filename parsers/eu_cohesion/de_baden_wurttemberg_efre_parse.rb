require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBadenWurttembergEfreParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    resource = resources.detect {|r| r.web_resource.uri == 'http://www.rwb-efre.baden-wuerttemberg.de/doks/Transparenzliste_31-12-2008.pdf'}
    parse resource
  end

  def parse resource
    formats = [:string, /.+/, /^\d\d\d\d$/, /^(\d|\.)*\,\d\d$/]
    groups = get_text_groups(resource, formats, 'text[@font="4"]')
    @projects = []

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 4
        keys = by_position.keys.sort

        if by_position.keys.size == 5 && by_position[keys.first].first.value[/(GmbH|GmbH & Co.KG)$/] && by_position[keys.second].size == 1
          by_position[keys.third] = by_position[keys.second] + by_position[keys.third]
          by_position.delete(keys.second)
        else
          raise by_position.keys.inspect + ': ' + group.inspect + ' -> ' + by_position.to_yaml
        end
      end
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_baden_wurttemberg_efre.csv'
  end

  def add_project by_position, resource
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip
      unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/] && !value[/Neubau einer Lager|Kauf einer CNC|Neubau einer Produktionshalle|Bau eines neuen Betriebsgebäudes/]
      end
      if texts.first.left.to_i > 700
        project.morph(:ausgezahlter_betrag_bei_projektabschluss, value)
      else
        project.morph(attribute_keys[index], value)
      end
    end
    project.fund_type = 'EFRE'
    project.currency = 'EUR'
    project.uri = resource.uri
    @projects << project
  end

  def attribute_keys
    [
    :name_des_begunstigten,
    :bezeichnung_des_vorhabens,
    :jahr_bewilligung,
    :bewilligter_betrag,
    :ausgezahlter_betrag_bei_projektabschluss,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def first_data_value
    'Acandis GmbH & Co.KG'
  end

  def split_this text
    case text
    when /^(.+ GmbH)  (.+)$/
      [$1,$2]
    when /^(.+ GmbH & Co.KG)  (.+)$/
      [$1,$2]
    when /2008 1.285.200,00/
      ['2008','1.285.200,00']
    when /2008 3.545.800,00/
      ['2008','3.545.800,00']
    when /Werner Mitsch Holding GmbH Kauf eines neuen  Schweißroboters/
      ['Werner Mitsch Holding GmbH','Kauf eines neuen  Schweißroboters']
    when /Friedhelm & Holger Haag GbR Kauf einer CNC-Schweißraupen-Verputzmaschine/
      ['Friedhelm & Holger Haag GbR','Kauf einer CNC-Schweißraupen-Verputzmaschine']
    when /Hans Riebel GmbH & Co.KG  Kauf einer Lackiermaschine/
      ['Hans Riebel GmbH & Co.KG','Kauf einer Lackiermaschine']
    else
      nil
    end
  end
  
end
