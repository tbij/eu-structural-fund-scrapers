require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItEmiliaRomagnaAsseIiErdfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  def parse resource
    formats = [:string, /^.+$/, /^\d\d\d\d$/, /^((\d|\.)*\,\d\d)$/]
    groups = get_text_groups(resource, formats, 'text[@font="0"]') do |xml|
      xml.sub!('<text top="128" left="81" width="55" height="17" font="0">             </text>',
        '')
            xml.gsub!(/<text ([^>]+)>\s+<\/text>/, '')
    end
    @projects = []

    by_position(groups) do |group, by_position|
      parts_count = by_position.keys.size
      expected = 4
      if parts_count != expected
        values = by_position.values
        values = values.collect {|x| x.collect(&:value).join("\n") }
        raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
      end
      @previous = by_position
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_emilia_romagna_asse_ii_erdf.csv'
  end

  def add_project by_position, resource
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip

      unless true || @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/] && !value[/BRIDGES HYDRAULIC|BRIDGE 129|EAN 13 COLLECTION/]
      end

      project.morph(attribute_keys[index], value)
    end
    project.fund_type = 'ERDF'
    project.currency = 'EUR'
    project.uri = resource.uri
    @projects << project
  end

  def attribute_keys
    [
    :ragione_sociale,
    :denominazione_dell_operazione,
    :anno_finanziamento_pagamento,
    :contributo_concesso_risorse_nazionali_ecomunitarie,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def first_data_value
    '3 BRIDGES HYDRAULIC'
  end
  
  def split_this text
    case text
    when /^(NUOVA S.I.D.E.R. S.R.L.) (Aumento.*)$/
        [$1,$2]
      when /^(S.A.C.S. TECNICA SRL) (Aumento.*)$/
        [$1,$2]
      else
        nil
    end
  end
end
