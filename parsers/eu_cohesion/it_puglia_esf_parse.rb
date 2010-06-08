require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItPugliaEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  IGNORE = [
'>Pagina '
]
  IGNORE_RE = /#{IGNORE.join('|')}/

  def parse resource
    formats = [:string, /^\d$/, /^.+$/, /^(((\d|\.)+\,\d\d)|(0,00))$/]

    groups = get_text_groups(resource, formats, 'text[@font="3"]') do |xml|
      
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')
      
      lines = []
      
      xml.each_line do |line|
        unless line[IGNORE_RE]
          lines << line.strip
        end
      end
      
      xml = lines.join("\n")

      xml.sub!('<text top="740" left="10" width="111" height="14" font="3">AZZARETTI FLAVIA</text>',
        '<text top="739" left="10" width="111" height="14" font="3">AZZARETTI FLAVIA</text>')
      
      xml.sub!('<text top="770" left="10" width="97" height="14" font="3">AZZOLINI ELENA</text>',
        '<text top="769" left="10" width="97" height="14" font="3">AZZOLINI ELENA</text>')
      
      xml.sub!('<text top="755" left="10" width="109" height="14" font="3">AZZARETTI GIULIA</text>',
        '<text top="754" left="10" width="109" height="14" font="3">AZZARETTI GIULIA</text>')
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
      expected = 4
      
      parts_count = by_position.keys.size
      if parts_count != expected
        values = by_position.values
        values = values.collect {|x| x.collect(&:value).join("\n") }
        raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
      end

      @previous = by_position
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_puglia_esf.csv'
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
    'ABATE MARCELLO'
  end

  def attribute_keys
    [
    :nominativo_beneficiario,
    :asse,
    :denominazione_dell_operazione,
    :importo_finanziamento_pubblico_dell_operazione,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
end
