require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBayern2007EsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  def fix_top xml, text
    xml.sub!(text, text.sub('top="407"','top="408"') )
  end

  IGNORE = [
'Verzeichnis der Begünstigten:',
'Zukunft in Bayern, Europäischer Sozialfonds, Regionale Wettbewerbsfähigkeit und Beschäftigung Bayern 2007-2013',
'aktualisiert: 05.09.2008',
'Stichtag: 31.12.2007',
'Liste der Begünstigten Bayern:',
'Projekt',
'Auszahlung von öffentl. Mitteln an die Begünstigten',
'Fördera',
'lfd. Nr.',
'Name des Begünstigten',
'Bewilligungs-',
'Bewilligter ',
'Ausbezahlter Betrag ',
'ktivität',
'jahr',
'Betrag in Euro',
'zum Projektende',
'Name des Projekts'
]
  IGNORE_RE = /#{IGNORE.join('|')}/

  def parse resource
    formats = [:string, :string, :string, :string, /^\d\d\d\d$/, /^((\d+\,\d\d)|(\d+)|0)$/, /^0$/]

    groups = get_text_groups(resource, formats, 'text[@font="0"]') do |xml|
      
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')
      
      lines = []
      
      xml.each_line do |line|
        unless line[IGNORE_RE]
          lines << line.strip
        end
      end
      
      xml = lines.join("\n")

      xml.gsub!('<text top="579" left="159" width="207" height="17" font="0">Bäckerei, Horst Schellenberger</text>',
'<text top="580" left="159" width="207" height="17" font="0">Bäckerei, Horst Schellenberger</text>')

      xml.gsub!('<text top="579" left="651" width="125" height="17" font="0">Ausbildungsstellen</text>',
'<text top="580" left="651" width="125" height="17" font="0">Ausbildungsstellen</text>')
      
      xml.sub!('<text top="756" left="69" width="25" height="17" font="0">161</text>',
        '<text top="765" left="69" width="25" height="17" font="0">161</text>')

  
      xml.gsub!('<text top="690" left="159" width="149" height="17" font="0">Bäckerei, Karl Küspert</text>',
        '<text top="691" left="159" width="149" height="17" font="0">Bäckerei, Karl Küspert</text>')
      
      xml.gsub!('<text top="690" left="651" width="125" height="17" font="0">Ausbildungsstellen</text>',
        '<text top="691" left="651" width="125" height="17" font="0">Ausbildungsstellen</text>')

      xml.sub!('<text top="447" left="69" width="25" height="17" font="0">419</text>',
        '<text top="452" left="69" width="25" height="17" font="0">419</text>')

      xml.sub!('<text top="453" left="123" width="8" height="17" font="0">6</text>',
        '<text top="452" left="123" width="8" height="17" font="0">6</text>')      
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

      prefix = %Q|<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE pdf2xml SYSTEM "pdf2xml.dtd">
<pdf2xml>|
      xml = "#{prefix}\n#{pages.join("\n<page ")}\n</pdf2xml>"

      # xml.gsub!(/<text\s([^>]+)>\s*(((\d|\.)*\,\d\d))\s*<\/text>\n<text\s([^>]+)>\s*(((\d|\.)*\,\d\d))\s*<\/text>/,
        # '<text \1>\2 \6</text>')

      # xml.gsub!(/<text\s([^>]+)>\s*((\d+\.(\d|\.)*))\s*<\/text>\n<text\s([^>]+)>\s*((\d+\.(\d|\.)*))\s*<\/text>/,
        # '<text \1>\2,00 \6,00</text>')

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
      
      xml.sub!('<text top="520" left="228" width="29" height="17" font="1">6/1a</text>
<text top="520" left="563" width="130" height="17" font="1">Praxisklassen 2007</text>',
'<text top="520" left="228" width="29" height="17" font="1">6/1a</text>
<text top="520" left="453" width="29" height="17" font="1">-</text>
<text top="520" left="563" width="130" height="17" font="1">Praxisklassen 2007</text>')

      xml.gsub!('<text top="520" left="228" width="29" height="17" font="1">6/1b</text>
<text top="520" left="563" width="163" height="17" font="1">Ausbildungsstellen 2007</text>',
'<text top="520" left="228" width="29" height="17" font="1">6/1b</text>
<text top="520" left="453" width="29" height="17" font="1">-</text>
<text top="520" left="563" width="163" height="17" font="1">Ausbildungsstellen 2007</text>')
      
      xml.gsub!('<text top="520" left="228" width="29" height="17" font="1">6/1d</text>
<text top="520" left="563" width="130" height="17" font="1">Praxisklassen 2008</text>',
'<text top="520" left="228" width="29" height="17" font="1">6/1d</text>
<text top="520" left="453" width="29" height="17" font="1">-</text>
<text top="520" left="563" width="130" height="17" font="1">Praxisklassen 2008</text>')
      
      xml.gsub!('<text top="389" left="228" width="29" height="17" font="1">6/2a</text>
<text top="389" left="563" width="113" height="17" font="1">Altenpflege 2007</text>',
'<text top="389" left="228" width="29" height="17" font="1">6/2a</text>
<text top="389" left="453" width="29" height="17" font="1">-</text>
<text top="389" left="563" width="113" height="17" font="1">Altenpflege 2007</text>')
      
      xml.sub!('<text top="707" left="305" width="48" height="17" font="1">Bayern</text>
<text top="707" left="453" width="1" height="17" font="1">-</text>
<text top="707" left="563" width="65" height="17" font="1">und Beruf</text>',
'<text top="707" left="305" width="48" height="17" font="1">Bayern</text>
<text top="707" left="563" width="65" height="17" font="1">und Beruf</text>')
      
      xml.sub!('<text top="670" left="1118" width="8" height="17" font="1">0</text>','')
      xml.sub!('<text top="707" left="1118" width="8" height="17" font="1">0</text>','')
      xml.sub!('<text top="183" left="1118" width="8" height="17" font="1">0</text>','')
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
      if parts_count != 7
        values = by_position.values.collect {|x| x.collect(&:value).join("\n") }.join("\n")
        raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values}\nexpected 7 items, got #{parts_count}\n#{@previous.inspect}"
      end
      
      @previous = by_position
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_bayern_2007_esf.csv'
  end

  def add_project by_position, resource
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip
      unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/] && !value[/Gestalter im Handwerk|Gemeinde Scheyern|Stegmaier Michael|Christian Werkstatt|C1-Servicefachkraft/] && !value[/^((\d|\.)*\,\d\d)$/]
      end

      project.morph(attribute_keys[index], value)
    end
    project.fund_type = 'ESF'
    project.currency = 'EUR'
    project.uri = resource.uri

    @projects << project
  end

  def first_data_value
    '1'
  end

  def attribute_keys
    [
    :lfd_nr,
    :forderaktivitat,
    :name_des_begunstigten,
    :name_des_projekts,
    :bewilligungs_jahr,
    :bewilligter_betrag_in_euro,
    :ausbezahlter_betrag_zum_projektende,
    :fund_type,
    :currency,
    :uri
    ]
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
