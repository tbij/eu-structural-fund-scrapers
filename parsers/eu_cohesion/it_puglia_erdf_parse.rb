require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItPugliaErdfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  NUMBER = /^((\d|\.)+\,\d\d)$/

  IGNORE = []
  IGNORE_RE = /\d\/18/

  def group_text text
    @started = true if start_of_data(text)
    if @started
      if has_string_value?(text)
        @stack << text unless ignore_this[text.value.strip]
      else
        $stderr.write text.inspect
      end
      text = @stack[-2]
      last_text = @stack[-1]

      if last_text.value.strip[/2008   €              187.080,00/]
        @groups << @stack
        @stack = []
      elsif has_string_value?(text) && (text.value.strip[/((\d|\.)+\,\d\d)/])
        if has_string_value?(last_text)
          if !last_text.value.strip[/((\d|\.)+\,\d\d)/]
            start_next = @stack.pop
            @groups << @stack
            @stack = [start_next]
          end
        end
      end
    end
  end
  
  def parse resource
    groups = get_text_groups(resource, [], 'text[@font="3"]') do |xml|
      lines = []
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')
      xml.gsub!(/<text ([^>]+)><b>\s+<\/b><\/text>\n/,'')
      xml.each_line do |line|        
        lines << line.strip unless line[IGNORE_RE]
      end
      xml = lines.join("\n")
      
      File.open('/Users/x/junk.xml','w') do |f|
        f.write xml
      end
      xml
    end
    
    puts groups.size

    @projects = []

    @previous = nil
    by_position(groups) do |group, by_position|
      expected = 3
      
      parts_count = by_position.keys.size

      if parts_count != expected
        # if parts_count == 2
          # first_key = @previous.keys.sort[0]
          # second_key = @previous.keys.sort[1]
          # by_position[first_key] = @previous[first_key]
          # by_position[second_key] = @previous[second_key]
        # elsif parts_count == 3
          # first_key = @previous.keys.sort[0]
          # by_position[first_key] = @previous[first_key]
        # else
          values = by_position.values
          values = values.collect {|x| (values.index(x)+1).to_s + ' ' + x.collect(&:value).join("\n") }
          raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
        # end
      end

      @previous = by_position
      add_project(by_position, resource)
    end

    # @projects.each do |project|
      # if project.anno_di_pagamento_finale && project.anno_di_pagamento_finale[NUMBER]
        # if project.ammontare_assegnato.blank?
          # project.ammontare_assegnato = project.anno_di_pagamento_finale
          # project.anno_di_pagamento_finale = nil
        # end
      # end
    # end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_puglia_erdf.csv'
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
    "Acquedotto  Pugliese"
  end

  def attribute_keys
    [
    :nominativo_del_beneficiario,
    :denominazione_dell_operazione,
    :importo_finanziamento_pubblico_dell_operazione,
    :fund_type,
    :currency,
    :uri
    ]
  end

  def split_this text
    case text.gsub('€','').strip
    when /^(Comune di Carlantino)  (Comune di Carlantino.+)$/
      [$1,$2]
    when /^(Comune di Cutrofinao)  (Bonifica Cave Ipogee CUTROFIANO)$/
      [$1,$2]
    when /^(Comune di Trinitapoli)  (Bonifica  c.da Mattoni - Canale 5 metri – Trinitapoli)$/
      [$1,$2]
    when /^(NUOVA CONCORDIA - FED CUP ITALIA RUSSIA)$/
      ['Regione Puglia',$1]
    when /^(Comune di Canosa di Puglia)  (.+)$/      
      [$1,$2]
    when /^(Arcidiocesi di Bari - Bitonto)  (.+)$/
      [$1,$2]
    when /^(Acquedotto  Pugliese S.p.A.)  (Inventariazione dell' Archivio Storico dell'Ente AQP)$/
      [$1,$2]
    when /^(Ferrovie del Sud Est)  (.+)$/
      [$1,$2]
    else
      nil
    end
  end

end
