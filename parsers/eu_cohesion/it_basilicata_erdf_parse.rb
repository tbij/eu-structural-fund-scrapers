require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItBasilicataErdfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  NUMBER = /^((\d|\.)+\,\d\d)$/

  IGNORE = []
  IGNORE_RE = /#{IGNORE.join('|')}/

  def group_text text
    @started = true if start_of_data(text)
    if @started
      if has_string_value?(text)
        @stack << text unless ignore_this[text.value.strip]
      else
        $stderr.write text.inspect
      end
      text = @stack[-2]
      if has_string_value?(text) && text.value.strip[NUMBER]
        last_text = @stack[-1]
        if has_string_value?(last_text) && (!last_text.value.strip[NUMBER] || last_text.value.strip == '167.665.529,81')
          start_next = @stack.pop
          @groups << @stack
          @stack = [start_next]
        end
      end
    end
  end
  
  def parse resource
    groups = get_text_groups(resource, [], 'text[@font="3"]') do |xml|
      xml.gsub!('font="4"','font="3"')      
      File.open('/Users/x/junk.xml','w') do |f|
        f.write xml
      end
      xml
    end
    
    puts groups.size

    @projects = []

    @previous = nil
    by_position(groups) do |group, by_position|
=begin
      expected = 16
      
      parts_count = by_position.keys.size

      if parts_count != expected
        if parts_count == 15
          # ignore
        else
          values = by_position.values
          values = values.collect {|x| (values.index(x)+1).to_s + ' ' + x.collect(&:value).join("\n") }
          raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
        end
      end

      @previous = by_position
=end      
      add_project(by_position, resource)
    end

    @projects.each do |project|
      if project.anno_di_pagamento_finale && project.anno_di_pagamento_finale[NUMBER]
        if project.ammontare_assegnato.blank?
          project.ammontare_assegnato = project.anno_di_pagamento_finale
          project.anno_di_pagamento_finale = nil
        end
      end
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_basilicata_erdf.csv'
  end

  def add_project by_position, resource
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip
      unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        # raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/] && !value[/^(“INNOVAZIONE DI PROCESSO|Corso di preparazione|Progetto formativo per alunni stranieri|Progetto formativo di italiano|CORSO DI FORMAZIONE TEORICO|Corso apprendisti - )/] && !value[/^((\d|\.)*\,\d\d)$/]
      end

      project.morph(attribute_keys[index], value)
    end
    project.fund_type = 'ERDF'
    project.currency = 'EUR'
    project.uri = resource.uri

    @projects << project
  end

  def first_data_value
    "AMMINISTRAZIONE PROVINCIALE DI"
  end

  def attribute_keys
    [
    :nome_dei_beneficiari,
    :titolo_progetto,
    :asse,
    :linea_di_intervento,
    :anno_di_assegnazione_finanziamento,
    :anno_di_pagamento_finale,
    :ammontare_assegnato,
    :totale_importo_pagato_alla_fine_dell_operazione,
    :fund_type,
    :currency,
    :uri
    ]
  end
=begin
  def split_this text
    case text.gsub('€','').strip
    when /^((\d|\.)+,\d\d)\s+((\d|.)+,\d\d)$/
      [$1,$3]
    when /^((\d|\.)+,\d\d)$/
      ['0,00',$1]
    when /^(.+)\s(I1\)1\s.+)$/
      [$1,$2]
    when /^(.+)\s(I2\)\.1.+)$/
      [$1,$2]
    when /^(.+) (\d\d\d\d\d\d\d\d\d\d\d)$/
      [$1,$2]
    else
      nil
    end
  end
=end
end
