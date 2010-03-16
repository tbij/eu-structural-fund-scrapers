require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeHamburgEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    resource = resources.detect {|r| r.uri == 'http://www.esf-hamburg.de/contentblob/1379164/data/liste-gefoerderter-projekte.pdf'}
    parse resource
  end
  
  def parse resource
    date_format = /^\d\d\.\d\d\.\d\d$/
    formats = [:string, :string, :string, date_format, date_format, /^(\d|\.)+ .+$/]
    groups = get_text_groups(resource, formats, 'text[@font="1"]')
    @projects = []

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 6
        raise by_position.keys.inspect + ': ' + group.inspect + ' -> ' + by_position.inspect
      end

      project = EuCohesion::Project.new
      by_position.keys.sort.each_with_index do |key, index|
        value = by_position[key].collect(&:value).join(' ').squeeze(' ').chomp(' !').strip
        unless @pdf_text.include?(value) || @plain_pdf_text.include?(value) || value[/[A-Z]\s\d/]
          raise "#{value} not found in pdf text" unless value.include?(' ­ ')
        end
        project.morph(attribute_keys[index], value)
      end
      project.fund_type = 'ESF'
      project.uri = resource.uri
      @projects << project
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_hamburg_esf.csv'
  end

  def attribute_keys
    [
      :aktion,
      :zuwendungsempfanger,
      :projekt,
      :beginn,
      :ende,
      :projektvolumen,
      :fund_type,
      :uri
    ]
  end
  
  def first_data_value 
    'B 2'
  end

  def split_this text
    case text
    when /^(.+ GmbH)  (.+)$/
      [$1,$2]
    when /^(.+ GmbH & Co.KG)  (.+)$/
      [$1,$2]
    when /^(\d\d\.\d\d\.\d\d) (\d\d\.\d\d\.\d\d)$/
      [$1, $2]
    else
      nil
    end
  end

  def ignore_this
    {
      'Verzeichnis der Begünstigten' => true,
      'Stand Januar 2010' => true
    }
  end
  
end
