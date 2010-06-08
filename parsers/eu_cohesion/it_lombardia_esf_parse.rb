require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItLombardiaEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  NUMBER = /^(((\d|\.)+\,\d\d)|(0,00))$/

  IGNORE = [
'>Beneficiario ',
'>Titolo ',
'>Quota ',
'>azione ',
'>assegnata ',
'<b> </b>'
]
  IGNORE_RE = /#{IGNORE.join('|')}/

  def group_text text
    @started = true if start_of_data(text)
    if @started
      if has_string_value?(text)
        @stack << text unless ignore_this[text.value.strip]
      else
        $stderr.write text.inspect
      end
      if format_match(-1) && format_match(-2)
        @groups << @stack
        @stack = []
      end
    end
  end

  def parse resource
    formats = [/^.+$/, NUMBER]

    groups = get_text_groups(resource, formats, 'text[@font="2"]') do |xml|
      xml.gsub!(%Q|font="3"|, %Q|font="2"|)
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')

      lines = []
      xml.each_line do |line|        
        lines << line.strip unless line[IGNORE_RE]
      end
      xml = lines.join("\n")

      xml.gsub!(/(<text[^>]+>(((\d|\.)+\,\d\d)|(0,00))\s*<\/text>)\n<text[^>]+>(((\d|\.)+\,\d\d)|(0,00))\s*<\/text>/) do |text|
        keep = $1
      end
      
      xml.sub!('<text top="451" left="1089" width="71" height="17" font="2">2.166.000 </text>',
        '<text top="451" left="1089" width="71" height="17" font="2">2.166.000,00 </text>')
      
      xml.sub!('<text top="520" left="1101" width="58" height="17" font="2">177.600 </text>',
        '<text top="520" left="1101" width="58" height="17" font="2">177.600,00 </text>')
      
      xml.sub!('<text top="372" left="399" width="387" height="17" font="0">Sovvenzione Globale denominata &quot;Learning Week&quot; (Doti) </text>',
        '<text top="358" left="399" width="387" height="17" font="2">Sovvenzione Globale denominata &quot;Learning Week&quot; (Doti) </text>')

      File.open('/Users/x/junk.xml','w') do |f|
        f.write xml
      end
      xml
    end
    
    puts groups.size

    @projects = []

    @previous = nil
    @beneficiary = nil
    by_position(groups) do |group, by_position|
      parts_count = by_position.keys.size
      expected = 3
      
      parts_count = by_position.keys.size      
      @beneficiary = by_position if parts_count == 3

      if parts_count != expected
        if parts_count == 2
          first_key = @beneficiary.keys.sort.first
          by_position[first_key] = @beneficiary[first_key]
        else
          values = by_position.values
          values = values.collect {|x| x.collect(&:value).join("\n") }
          raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
        end
      end

      @previous = by_position
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_lombardia_esf.csv'
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
    "A&I - SOCIETA' COOPERATIVA SOCIALE"
  end

  def attribute_keys
    [
    :beneficiario,
    :titolo_azione,
    :quota_per_singola_azione,
    :fund_type,
    :currency,
    :uri
    ]
  end

=begin
  def split_this text
    case text
    when /^(.+\d\d\d\/\d\d?\/\d) (.+)$/
      [$1,$2]
    when /^(\d\.\d\d\d\.\d\d\d,\d\d)  (\d\.\d\d\d\.\d\d\d,\d\d)$/
      [$1,$2]
    else
      nil
    end
  end
  def split_this text
    case text
      when /^(.+) (\d\d\d\d\d\d) ((Progetto|Creazione|Consulenza|Voucher|Tirocini) .+)$/
        [$1, $2, $3]
      when /^(.+) (\d\d\d\d\d\d) (Voucher)$/
        [$1, $2, $3]
      when /^(\d\d\d\d\d\d) ((Progetto|Creazione|Consulenza|Voucher|Tirocini) .+)$/
        [$1, $2]
      when /^(\d\d\d\d\d\d?) (Work Experience|Voucher)$/
        [$1, $2]
      when /^(biotecnologie in diagnostica molecolare) (111844)$/
        [$1, $2]
      when /^(Provincia di .+) (Borsa lavoro)$/
        [$1, $2]
      when /^(TNT GLOBAL EXPRESS) (LINGUA ESTERA .+)$/
        [$1, $2]
      else
        nil
    end
  end
  def split_this text
    case text
    when /^((\d|\.)*\,\d\d)\s*((\d|\.)*\,\d\d)\s*$/
      [$1,$3]
    when /^((\d)*\,\d\d)\s*((\d)*\,\d\d)\s*$/
      [$1,$3]
    when /^(.+) (Existenzgr.*)$/
      [$1,$2]
    when /^(.+) (Altenpflege 2007)/
      [$1,$2]
    else
      nil
    end
  end
=end
# 
  # def ignore_this
    # {
# 'Filter: ESF' => true,
# 'Datenquelle: Indikativer Finanzplan ESF / VERA' => true,
# 'Stand der Daten: 15 Jan 2010 06:33:56' => true,
# 'Alle Angaben in Euro' => true
    # }
  # end
  
end
