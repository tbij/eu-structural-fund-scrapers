require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItEmiliaRomagnaAsseIiiErdfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  def group_text text
    @started = true if start_of_data(text)
    if @started
      if has_string_value?(text)
        @stack << text unless ignore_this[text.value.strip]
      else
        $stderr.write text.inspect
      end
      if format_match(-1) && format_match(-2) && format_match(-3) && format_match(-4) && format_match(-5) && format_match(-6)
        @groups << @stack
        @stack = []
      end
    end
  end

  NUMBER = /^((\d|\.)*\,\d\d)|-$/
  def parse resource
    formats = [:string, :string, :string, /\d\d\d\d/, NUMBER, NUMBER, NUMBER, NUMBER, NUMBER]

    groups = get_text_groups(resource, formats, 'text[@font="1"]') do |xml|
      xml.gsub!(/<text ([^>]+)>\s+<\/text>/, '')
      xml
    end
    @projects = []

    by_position(groups) do |group, by_position|
      parts_count = by_position.keys.size
      expected = 9
      if parts_count != expected
        extra = parts_count - expected 
        keys = by_position.keys
        while (parts_count > expected) && extra !=0
          to_append = keys[2]
          to_remove = keys[3]
          puts to_remove.inspect
          if to_remove
            by_position[to_append].last.value = "#{by_position[to_append].last.value} #{by_position[to_remove].collect(&:value).join("\n")}"
            by_position.delete(to_remove)
            keys = by_position.keys
          end
          extra = extra - 1
        end
        parts_count = by_position.keys.size
        if parts_count != expected
          values = by_position.values
          values = values.collect {|x| x.collect(&:value).join("\n") }
          raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
        end
      end
      @previous = by_position
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_emilia_romagna_asse_iii_erdf.csv'
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
    :ragione_sociale_impresa,
    :prov,
    :descrizione_intervento,
    :anno_finanziamento_o_pagamento,
    :contributo_totale_concesso,
    :contributo_quota_fesr,
    :contributo_quota_mezzi_stato,
    :contributo_quota_regione_cap,
    :quota_liquidata,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def first_data_value
    'ALMA PETROLI S.P.A.'
  end
  
  def split_this text
    case text
      when /^(\s|\d|,|\.|-)+$/
        text.split(' ')
      when /^(MARCHINI PIERGIORGIO) (PR)$/
        [$1,$2]
      else
        nil
    end
  end
end
