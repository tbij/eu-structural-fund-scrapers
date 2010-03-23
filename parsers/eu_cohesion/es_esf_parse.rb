require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::EsEsfParse

  include EuCohesion::ParserBase

  def perform result
    resource = result.scraped_resources.first
    @projects = []
    @first_data_value = '2007ES051PO002'
    parse resource, '1'

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/es_esf.csv'
  end

  def parse resource, font_number
    formats = [:string, :string, /.+/, /^(\d|\.)+\d$/, /^(\d|\.)+\d$/]
    groups = get_text_groups(resource, formats, 'text[@font="'+font_number+'"]')

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 5
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
    project.fund_type = 'ESF'
    project.currency = 'EUR'
    project.uri = resource.uri
    @projects << project
  end

  def attribute_keys
    [
    :cci,
    :po,
    :organismo_intermedio,
    :coste_total,
    :ayuda_fse,
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
  def ignore_this
    [
      'PROGRAMAS OPERATIVOS 2007-2013',
      'Dotación 2007',
      'CCI',
      'PO',
      'Organismo Intermedio',
      'Coste Total',
      'Ayuda FSE'
      ].inject({}) {|h,x| h[x] = true; h}
  end
  
end
