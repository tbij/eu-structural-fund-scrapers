require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::RoPoAt30Aprilie2010Parse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Ro april 2010 scrape')
    resources = result.scraped_resources
    uri = 'http://localhost:9999/Lista_contractate_PO_AT_30_aprilie_2010.pdf'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    parse resource
  end

  def group_text text
    is_start = start_of_data(text)
    @started = true if is_start

    if @started
=begin
      if has_string_value?(text)
        back_delta = text.back_delta && text.back_delta.to_i
        fwd_delta =   text.fwd_delta && text.fwd_delta.to_i
        
        if back_delta && fwd_delta
          puts "to move: #{text.value}"
          move_forward = fwd_delta < back_delta
          move_backwards = back_delta < fwd_delta
          
          left = text.left
          index = @texts.index(text)

          if move_forward
            next_index = index + 1
            next_text = @texts[next_index]
            while next_text && next_text.left != left
              next_index = next_index + 1
              next_text = @texts[next_index]
            end
            if next_text
              value = "#{text.value} #{next_text.value}".squeeze(' ')
              puts value
              next_text.value = value
            else
              @stack << text unless ignore_this[text.value.strip]
            end
          elsif move_backwards
            prev_index = index - 1
            prev_text = @texts[prev_index]
            while prev_index > -1 && prev_text && prev_text.left != left
              prev_index = prev_index - 1
              prev_text = @texts[prev_index]
            end
            value = "#{prev_text.value} #{text.value}".squeeze(' ')
            puts value
            prev_text.value = value
          else
            @stack << text unless ignore_this[text.value.strip]
          end
        else
          @stack << text unless ignore_this[text.value.strip]
        end
=end
      if has_string_value?(text)
        @stack << text unless ignore_this[text.value.strip]
      else
        $stderr.write text.inspect
      end
      if format_match(-1) && format_match(-2) && format_match(-3) && format_match(-4) && format_match(-5)
        @groups << @stack
        @stack = []
      end
    end
  end

  def correct_tops lines
    tops = lines.collect {|line| line[/top="(\d+)"/,1]}.compact.uniq.map(&:to_i).sort        
    (tops + []).each do |top|
      if tops.include?(top)
        one_pixel_down = (top + 1)
        if tops.include?(one_pixel_down)
          incorrect_top = %Q|top="#{one_pixel_down}"|
          corrected_top = %Q|top="#{top}"|
          lines = lines.collect {|line| line.sub(incorrect_top, corrected_top)}
          tops.delete(one_pixel_down)
        end
      end
    end
    lines
  end
  
  def top_deltas lines
    new_lines = []

    tops = lines.collect {|line| line[/top="(\d+)"/,1]}
    
    tops.each_with_index do |top, index|
      line = lines[index]

      if top && index > 0 && index < (tops.size - 1)
        top = top.to_i
        last_top = tops[index - 1].to_i
        last2_top = tops[index - 2].to_i
        next_top = tops[index + 1].to_i
        next2_top = tops[index + 2].to_i
        back_delta = top - last_top
        back2_delta = top - last2_top
        fwd_delta = next_top - top
        fwd2_delta = next2_top - top

        if (back_delta != 0 || back2_delta != 0) && (fwd_delta != 0 || fwd2_delta != 0)
          if back_delta != 0
            back_top = %Q| back_delta="#{back_delta}"|
          else
            back_top = %Q| back_delta="#{back2_delta}"|
          end
          if fwd_delta != 0
            fwd_top =  %Q| fwd_delta="#{fwd_delta}"|
          else
            fwd_top =  %Q| fwd_delta="#{fwd2_delta}"|
          end
          line.sub!(%Q|top="#{top}"|, %Q|top="#{top}"#{back_top}#{fwd_top}|)
        end
        new_lines << line
      else
        new_lines << line
      end
    end

    new_lines    
  end

  NUMBER = /^(((\d?\d?\d\.)*\d\d\d)|0)$/

  def fix_texts texts
    lefts = texts.map(&:left)
    texts.each_with_index do |text, index|
      if text.left == '268' && (upto = lefts.last(lefts.size - (index +1)).index('268'))
        if upto > 0
          upto.times do |i|
            i = i + 1
            text.value = "#{text.value} #{texts[index + i].value}".squeeze(' ')
            texts[index + i].value = ''
            puts text.value
          end
        end
      end
    end
    
    texts.delete_if {|x| x.value.blank?}
    
    lefts = texts.map(&:left)
    if texts.size > 9
      fixed = false
      texts.each_with_index do |text, index|
        if !fixed && text.left.to_i > 268
          i = index+1
          next_text = texts[i]
          while !next_text.value[/^Axa/]
            text.value = "#{text.value} #{texts[i].value}".squeeze(' ')
            texts[i].value = ''
            i += 1
            next_text = texts[i]        
          end
          fixed = true
        end
      end
    end

    texts.delete_if {|x| x.value.blank?}

    lefts = texts.map(&:left)
    if texts.size > 9
      fixed = false
      texts.each_with_index do |text, index|
        if !fixed && text.value[/^Axa/]
          i = index+1
          next_text = texts[i]
          while !next_text.value[NUMBER]
            text.value = "#{text.value} #{texts[i].value}".squeeze(' ')
            texts[i].value = ''
            i += 1
            next_text = texts[i]        
          end
          fixed = true
        end
      end
    end
    
    texts.delete_if {|x| x.value.blank?}
    
    texts
  end

  def parse resource
    formats = [:string, :string, :string, :string, NUMBER, NUMBER, NUMBER, NUMBER, NUMBER]

    groups = get_text_groups(resource, formats, 'text[@font="2"]') do |xml|      
      xml.sub!('<text top="381" left="268" width="27" height="7" font="4">unităţilor</text>',
               '<text top="381" left="268" width="27" height="7" font="4">unităţilor de evaluare din cadrul</text>')

      xml.sub!('<text top="381" left="302" width="7" height="7" font="3">de</text>','')
      xml.sub!('<text top="381" left="317" width="25" height="7" font="3">evaluare</text>','')
      xml.sub!('<text top="381" left="349" width="9" height="7" font="3">din</text>','')
      xml.sub!('<text top="381" left="366" width="18" height="7" font="3">cadrul</text>', '')

      xml.sub!('<text top="753" left="817" width="29" height="7" font="3">2.530.365</text>
<text top="753" left="875" width="29" height="7" font="3">8.325.918</text>
<text top="753" left="927" width="33" height="7" font="2"><b>20.977.743</b></text>', '')
      
      xml.sub!('<text top="753" left="679" width="33" height="7" font="3">10.121.460</text>
<text top="753" left="763" width="4" height="7" font="3">0</text>',
'<text top="753" left="679" width="33" height="7" font="3">10.121.460</text>
<text top="753" left="763" width="4" height="7" font="3">0</text>
<text top="753" left="817" width="29" height="7" font="3">2.530.365</text>
<text top="753" left="875" width="29" height="7" font="3">8.325.918</text>
<text top="753" left="927" width="33" height="7" font="2"><b>20.977.743</b></text>')
      
      xml.sub!('<text top="587" left="677" width="36" height="7" font="2"><b>119.055.927</b></text>
<text top="587" left="751" width="29" height="7" font="2"><b>2.906.692</b></text>
<text top="587" left="815" width="33" height="7" font="2"><b>22.224.795</b></text>
<text top="587" left="873" width="33" height="7" font="2"><b>28.501.986</b></text>
<text top="587" left="925" width="36" height="7" font="2"><b>172.689.400</b></text>
<text top="587" left="427" width="25" height="7" font="2"><b>TOTAL</b></text>', '')
      xml.gsub!('font="3"','font="2"')
      xml.gsub!('font="4"','font="2"')
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')      

      File.open('/Users/x/junk.xml','w') do |f|
        f.write xml
      end
      xml
    end
=begin
      parts = xml.split('<pdf2xml>')
      pages = parts.last.split('<page ')
      pages = pages.collect do |page|
        lines = page.split("\n")        
        lines = correct_tops(lines)
        
        lines = lines.sort do |a,b|
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
        end
        lines = top_deltas(lines)        
        lines.join("\n")
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
=end
    puts groups.size

    @projects = []

    @previous = nil
    
    @groups.each do |group|
      fix_texts(group)
    end
    by_position(groups) do |group, by_position|
      parts_count = by_position.keys.size
      expected = 9
      if parts_count != expected

        # sorted_keys = by_position.keys.sort        
        # second_column_start = sorted_keys[1]
        # 
        # while 
        # 
        values = by_position.values
        values = values.collect {|x| x.collect(&:value).join("\n") }
        raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
      end
      @previous = by_position
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/ro_po_at_30_aprilie_2010.csv'
  end

  def add_project by_position, resource
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip
      # unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        # raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/] && !value[/Transerv 2000 Service|B3|B4|B5/]
      # end
      project.morph(attribute_keys[index], value)
    end
    project.currency = 'LEI'
    project.uri = resource.uri

    @projects << project
  end

  def first_data_value
    '2'
  end

  def attribute_keys
    [
    :nr_crt,
    :titlu_proiect,
    :nume_beneficiar,
    :nume_operatiune,
    :fonduri_ue,
    :buget_national,
    :contributie_beneficiar,
    :cheltuieli_neeligibile,
    :total_valoare_proiect,
    :currency,
    :uri
    ]
  end
=begin  
  def split_this text
    case text
    when /^((\d|\.)*\,\d\d)\s*((\d|\.)*\,\d\d)\s*$/
      [$1,$3]
    when /^((\d)*\,\d\d)\s*((\d)*\,\d\d)\s*$/
      [$1,$3]
    when /^((\d|\.)*\,\d\d)$/
      [$1,'0,00']
    when /^(.+) (Existenzgr.*)$/
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
=end  
end
