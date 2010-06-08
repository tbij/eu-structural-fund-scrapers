require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItEmiliaRomagnaEsfParse

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
      elsif has_string_value?(text) && (text.value.strip[/((\d|\.)+\,\d\d)/] || text.value.strip == '-')
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
    groups = get_text_groups(resource, [], 'text[@font="1"]') do |xml|
      lines = []
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')
      xml.gsub!(/<text ([^>]+)><b>\s+<\/b><\/text>\n/,'')
      xml.each_line do |line|        
        lines << line.strip unless line[IGNORE_RE]
      end
      xml = lines.join("\n")
      
      xml.sub!('<text top="631" left="177" width="349" height="13" font="1">Persone, incentivi alle persone per la formazione Totale</text>
<text top="631" left="723" width="104" height="13" font="1"> 17.250.000,00 </text>','')
      xml.sub!('<text top="697" left="177" width="163" height="13" font="1">Servizi alle persone Totale</text>
<text top="697" left="744" width="83" height="13" font="1"> 750.000,00 </text>','')
      
      xml.sub!('<text top="481" left="177" width="307" height="13" font="1">Persone, tirocini nella transizione al lavoro Totale</text>
<text top="481" left="752" width="75" height="13" font="1"> 17.640,00 </text>','')
      xml.sub!('<text top="879" left="71" width="414" height="13" font="1">Persone, IFTS (Istruzione e Formazione Tecnica Superiore) Totale</text>
<text top="879" left="744" width="83" height="13" font="1"> 160.000,00 </text>','')
      
      File.open('/Users/x/junk.xml','w') do |f|
        f.write xml
      end
      xml
    end
    
    puts groups.size

    @projects = []

    @previous = nil
    by_position(groups) do |group, by_position|
      expected = 4
      
      parts_count = by_position.keys.size

      if parts_count != expected
        if parts_count == 2
          first_key = @previous.keys.sort[0]
          second_key = @previous.keys.sort[1]
          by_position[first_key] = @previous[first_key]
          by_position[second_key] = @previous[second_key]
        elsif parts_count == 3
          first_key = @previous.keys.sort[0]
          by_position[first_key] = @previous[first_key]
        else
          values = by_position.values
          values = values.collect {|x| (values.index(x)+1).to_s + ' ' + x.collect(&:value).join("\n") }
          raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
        end
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

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_emilia_romagna_esf.csv'
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
    project.fund_type = 'ESF'
    project.currency = 'EUR'
    project.uri = resource.uri

    @projects << project
  end

  def first_data_value
    "IAL CISL"
  end

  def attribute_keys
    [
    :ragione_sociale,
    :azione,
    :titolo_operazione,
    :importo_approvato,
    :fund_type,
    :currency,
    :uri
    ]
  end

  def split_this text
    case text.gsub('€','').strip
    when /^(\d\d\d\d)\s+((\d|\.)+,\d\d)\s+((\d|.)+,\d\d)$/
      [$1,$2,$4]
    when /^(\d\d\d\d)\s+((\d|\.)+,\d\d)$/
      [$1,$2,'0,00']
    else
      nil
    end
  end
  
end
