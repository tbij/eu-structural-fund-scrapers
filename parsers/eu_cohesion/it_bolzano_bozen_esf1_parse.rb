require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItBolzanoBozenEsf1Parse

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
      elsif has_string_value?(text) && text.value.strip[/((\d|\.)+\,\d\d)/]
        if has_string_value?(last_text)
          if last_text.value.strip[/^(I|II|III|IV|V)$/]
            start_next = @stack.pop
            @groups << @stack
            @stack = [start_next]
          end
        end
      end
    end
  end
  
  def parse resource
    groups = get_text_groups(resource, [], 'text[@font="2"]') do |xml|
      lines = []
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')
      xml.gsub!(/<text ([^>]+)><b>\s+<\/b><\/text>\n/,'')
      xml.each_line do |line|        
        lines << line.strip unless line[IGNORE_RE]
      end
      xml = lines.join("\n")
      
      xml.sub!('<text top="130" left="154" width="103" height="11" font="2">&quot;L. Einaudi&quot; Bozen </text>','')
      xml.sub!('<text top="1052" left="154" width="175" height="11" font="2">Tourismus und Dienstleistungen </text>',
        '<text top="1052" left="154" width="175" height="11" font="2">Tourismus und Dienstleistungen &quot;L. Einaudi&quot; Bozen </text>')
      
      xml.sub!('<text top="1013" left="343" width="477" height="11" font="2">Pionieri Plus - Sistema Copernicus  2007   €              150.000,00    €            55.156,87  </text>',
'<text top="1013" left="343" width="477" height="11" font="2">Pionieri Plus - Sistema Copernicus  </text>
<text top="1013" left="345" width="477" height="11" font="2">2007   €              150.000,00    €            55.156,87  </text>')
      
      xml.sub!('<text top="905" left="343" width="373" height="11" font="2">ROECHLING PRODUCTION 2007  2007   €              125.518,00     </text>',
'<text top="905" left="343" width="373" height="11" font="2">ROECHLING PRODUCTION 2007</text>
<text top="905" left="345" width="373" height="11" font="2">2007   €              125.518,00     </text>')
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

    # @projects.each do |project|
      # if project.anno_di_pagamento_finale && project.anno_di_pagamento_finale[NUMBER]
        # if project.ammontare_assegnato.blank?
          # project.ammontare_assegnato = project.anno_di_pagamento_finale
          # project.anno_di_pagamento_finale = nil
        # end
      # end
    # end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_provincia_autonoma_bolzano_bozen_esf1.csv'
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
    "I"
  end

  def attribute_keys
    [
    :asse,
    :beneficiario,
    :operazione,
    :anno,
    :totale_importo_pubblico_approvato,
    :erogazioni_al,
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
