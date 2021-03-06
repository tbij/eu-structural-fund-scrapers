require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::RoPosCce30Aprilie2010Parse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Ro april 2010 scrape')
    resources = result.scraped_resources
    uri = 'http://localhost:9999/Lista_contractate_POS_CCE_30_aprilie_2010.pdf'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    parse resource
  end

  def group_text text
    is_start = start_of_data(text)
    @started = true if is_start

    if @started
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

  NUMBER = /^(((\d?\d?\d\.)*\d\d\d)|0)$/

  def fix_texts texts
    lefts = texts.map(&:left)
    texts.each_with_index do |text, index|
      if text.left == '275' && (upto = lefts.last(lefts.size - (index +1)).index('275'))
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
        if !fixed && text.left.to_i > 275
          i = index+1
          next_text = texts[i]
          while next_text && !next_text.value[/^(Axa|DMI|“Sprijinirea)/]
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
        if !fixed && text.value[/^(Axa|DMI|“Sprijinirea)/]
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

      xml.sub!('<text top="317" left="280" width="304" height="12" font="3">Aplicarea brevetelor de invenţie pe scară industrială de</text>',
               '<text top="317" left="275" width="304" height="12" font="3">Aplicarea brevetelor de invenţie pe scară industrială de</text>')

      xml.sub!('<text top="740" left="275" width="276" height="12" font="3">Axa Prioritara 2 din POS CCE – pentru 2008 - 2010</text>',
        '<text top="740" left="275" width="276" height="12" font="3">axa Prioritara 2 din POS CCE – pentru 2008 - 2010</text>')
      
      xml.sub!('<text top="767" left="1032" width="76" height="12" font="2"><b>2.225.559.522</b></text>
<text top="767" left="1147" width="66" height="12" font="2"><b>386.000.326</b></text>
<text top="767" left="1260" width="66" height="12" font="2"><b>838.712.790</b></text>
<text top="767" left="1370" width="66" height="12" font="2"><b>729.420.232</b></text>
<text top="767" left="1472" width="76" height="12" font="2"><b>4.179.692.870</b></text>
<text top="766" left="593" width="46" height="12" font="2"><b>TOTAL</b></text>', '')

      xml.gsub!('font="3"','font="2"')
      xml.gsub!('font="4"','font="2"')
      xml.gsub!(/<text ([^>]+)>\s+<\/text>\n/,'')      

      File.open('/Users/x/junk.xml','w') do |f|
        f.write xml
      end
      xml
    end
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

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/ro_pos_cce_30_aprilie_2010.csv'
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
    '1'
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

  def split_this text
    case text
    when /^(Alinierea ADERA PROMOTION la standardele europene)  (ADERA PROMOTION SRL)$/
      [$1,$2]
    when /^(Sistem informatic integrat la nivelul judetului Dambovita) (Consiliul Judetean Dambovita)$/
      [$1,$2]
    when /^(.+) (Axa Prioritară 4\/ DMI 4.2. RES)$/
      [$1,$2]
    else
      nil
    end
  end
=begin  

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
