require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItLiguriaEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  IGNORE = [
'>Pagina '
]
  IGNORE_RE = /#{IGNORE.join('|')}/

  NUMBER = /^(((\d|\.)+\,\d\d)|(0,00))$/

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
    formats = [:strings, /^.+$/, NUMBER, NUMBER]

    groups = get_text_groups(resource, formats, 'text[@font="5"]') do |xml|
      xml.gsub!(%Q|font="4"|, %Q|font="5"|)
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')
      
      lines = []
      xml.each_line do |line|        
        lines << line.strip unless line[IGNORE_RE]
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
            if (a_top - b_top).abs == 1
              a_top = b_top
            end
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
      expected = 6
      
      parts_count = by_position.keys.size
      if parts_count != expected
        
        if parts_count == 3
          @beneficiary = by_position
        elsif parts_count == 5
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

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_liguria_esf.csv'
  end

  def add_project by_position, resource
    if by_position.keys.size == 3
      # ignore
    else
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
  end

  def first_data_value
    'ABB S.P.A. POWER'
  end

  def attribute_keys
    [
    :ragione_sociale_beneficiario,
    :codice_operazione,
    :titolo_operazione,
    :anno_allocazione,
    :impegnato,
    :pagato,
    :fund_type,
    :currency,
    :uri
    ]
  end

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
  
end
