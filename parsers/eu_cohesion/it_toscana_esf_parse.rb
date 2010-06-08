require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItToscanaEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources

    @projects = []

    parse resources.first

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_toscana_esf.csv'
  end
  
  def first_data_value
    '121'
  end
    
  def parse resource
    formats = [:string, :string, /.+/, /^(\d|\.)*\,\d\d$/, /^(\d|\.)*\,\d\d$/]
    groups = get_text_groups(resource, formats, 'text[@font="4"]')

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 9
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
      # unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        # raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/]
      # end
      project.morph(attribute_keys[index], value)
    end
    project.fund_type = 'ESF'
    project.currency = 'EUR'
    project.uri = resource.uri
    @projects << project
  end

  def attribute_keys
    [
    :cod,
    :org_int,
    :titolo,
    :asse, 
    :anno,
    :stato,
    :ente_gestore,
    :costo,
    :finanziamento,
    :fund_type,
    :currency,
    :uri
    ]
  end

  def split_this text
    case text
      when /^(AGRICOLTURA SOCIALE AGRIS) (I Adattabilit.*)$/
        [$1,$2]
      when /^(.+) (IV Capitale Umano)$/
        [$1,$2]
      else
        nil
    end
  end

end
