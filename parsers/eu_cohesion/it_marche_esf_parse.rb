require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItMarcheEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  def fix_top xml, text
    xml.sub!(text, text.sub('top="407"','top="408"') )
  end

  IGNORE = [
'>Pagina '
]
  IGNORE_RE = /#{IGNORE.join('|')}/

  def parse resource
    formats = [:string, :string, :string, :string, /^\d\d\d\d$/, /^((\d|\.)+\,\d\d)$/, /^(((\d|\.)+\,\d\d)|(0,00)|)$/]

    groups = get_text_groups(resource, formats, 'text[@font="0"]') do |xml|
      
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')
      
      lines = []
      
      xml.each_line do |line|
        unless line[IGNORE_RE]
          lines << line.strip
        end
      end
      
      xml = lines.join("\n")

      parts = xml.split('<pdf2xml>')
      pages = parts.last.split('<page ')
      pages = pages.collect do |page|
        lines = page.split("\n")
        lines.sort do |a,b|
          if a.empty? || a[/<\/page>|fontspec/]
            1
          elsif b.empty? || b[/<\/page>|fontspec/]
            -1
          elsif a[/number=/]
            -1
          elsif b[/number=/]
            1
          else
            a_top = a[/top="(\d+)"/, 1].to_i
            b_top = b[/top="(\d+)"/, 1].to_i
            a_left = a[/left="(\d+)"/, 1].to_i
            b_left = b[/left="(\d+)"/, 1].to_i
            if a_top < b_top
              -1
            elsif a_top > b_top
              1
            elsif a_left < b_left
              -1
            elsif a_left > b_left
              1
            else
              raise 'error? ' + a + b
            end
          end
        end.join("\n")
      end

      prefix = %Q|<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE pdf2xml SYSTEM "pdf2xml.dtd">
<pdf2xml>|
      xml = "#{prefix}\n#{pages.join("\n<page ")}\n</pdf2xml>"

      lines = []
      left_position = 0
 
      xml.each_line do |line|
        if line[/left="(\d+)"/]
          new_left_position = $1
          if (new_left_position == '563') && (left_position == '305')
            top = line[/top="(\d+)"/,1]
            lines << %Q|<text top="#{top}" left="453" width="1" height="17" font="1">-</text>|
          end
          left_position = new_left_position
        end
        lines << line.strip
      end
      
      xml = lines.join("\n")

      xml.sub!('<text top="369" left="477" width="220" height="17" font="0">119040 Creazione di impresa NP</text>',
'<text top="369" left="475" width="220" height="17" font="0">Creazione Impresa - YouSpice.net di Baldoni Cristoforo</text>
<text top="369" left="477" width="220" height="17" font="0">119040 Creazione di impresa NP</text>')

      xml.sub!('<text top="543" left="477" width="220" height="17" font="0">121042 Creazione di impresa NP</text>',
'<text top="543" left="475" width="220" height="17" font="0">Voucher Aziendali - la mimosa di jonuzi enver</text>
<text top="543" left="477" width="220" height="17" font="0">121042 Creazione di impresa NP</text>')
      
      xml.sub!('<text top="404" left="477" width="220" height="17" font="0">121172 Creazione di impresa NP</text>',
'<text top="404" left="475" width="220" height="17" font="0">Voucher Aziendali - francesca creazioni sposa srl</text>
<text top="404" left="477" width="220" height="17" font="0">121172 Creazione di impresa NP</text>')

      regexp = /(<[^>]+>\d\d\d\d<\/[^>]+>)\n(<text([^>]+) left="(\d+)" ([^>]+)>((\d|\.)+\,\d\d)<\/[^>]+>)\n((<[^>]+>([^\d].+)<\/[^>]+>)|(<\/page>))/
      xml.gsub!(regexp) do |text|
        year = $1
        amount = $2
        before = $3
        left = $4.to_i + 2
        rest = $5
        last = $8
        
        %Q|#{year}\n#{amount}\n<text#{before} left="#{left}" #{rest}>0,00</text>\n#{last}|
      end
      
      regexp = /(<[^>]+>\d\d\d\d<\/[^>]+>)\n(<text([^>]+) left="(\d+)" ([^>]+)>((\d|\.)+\,\d\d)<\/[^>]+>)\n((<[^>]+>(\d\d\d\d\d\d) ((Progetto|Creazione|Consulenza|Voucher|Tirocini) [^<]+)<\/[^>]+>)|(<\/page>))/
      xml.gsub!(regexp) do |text|
        year = $1
        amount = $2
        before = $3
        left = $4.to_i + 2
        rest = $5
        last = $8
        
        %Q|#{year}\n#{amount}\n<text#{before} left="#{left}" #{rest}>0,00</text>\n#{last}|
      end
=begin
      xml.sub!('<text top="369" left="477" width="220" height="17" font="0">117540 Creazione di impresa NP</text>',
        '<text top="369" left="475" width="220" height="17" font="0">-</text>
<text top="369" left="477" width="220" height="17" font="0">117540 Creazione di impresa NP</text>')
      
      xml.sub!('<text top="426" left="477" width="220" height="17" font="0">117613 Creazione di impresa NP</text>'
'<text top="426" left="475" width="220" height="17" font="0">-</text>
<text top="426" left="477" width="220" height="17" font="0">117613 Creazione di impresa NP</text>')

      xml.sub!('<text top="596" left="477" width="220" height="17" font="0">118105 Creazione di impresa NP</text>'
'<text top="596" left="475" width="220" height="17" font="0">-</text>
<text top="596" left="477" width="220" height="17" font="0">118105 Creazione di impresa NP</text>')
=end
      File.open('/Users/x/junk.xml','w') do |f|
        f.write xml
      end
      xml
    end
    
    puts groups.size

    @projects = []

    @previous = nil
    by_position(groups) do |group, by_position|
      parts_count = by_position.keys.size
      expected = 7
      if parts_count == 5
        first_position = @previous.keys.sort.first
        second_position = @previous.keys.sort[1]
        by_position[first_position]  = @previous[first_position]
        by_position[second_position] = @previous[second_position]
      end

      if parts_count == 6
        first_position = @previous.keys.sort.first
        by_position[first_position] = @previous[first_position]
      end
      
      parts_count = by_position.keys.size
      if parts_count != expected
        values = by_position.values
        values = values.collect {|x| x.collect(&:value).join("\n") }
        raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
      end

      @previous = by_position
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_marche_esf.csv'
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
    '9000 UNO'
  end

  def attribute_keys
    [
    :nome_beneficiari,
    :denominazione_operazione,
    :codice_operazione,
    :tipo_operazione,
    :anno,
    :importo_impegnato,
    :importo_pagato,
    :fund_type,
    :currency,
    :uri
    ]
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
=begin
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
