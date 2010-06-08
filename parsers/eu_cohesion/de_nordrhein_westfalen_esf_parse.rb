require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeNordrheinWestfalenEsfParse

  include EuCohesion::ParserBase

  def perform result
    resource = result.scraped_resources.first
    parse resource
    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_nordrhein_westfalen_esf.csv'
  end

  def first_data_value
    '2006'
  end

  def final_format_match offset, values
    text = values[offset]
    text.strip[@formats[offset]]
  end

  def parse resource
    formats = [/^\d\d\d\d$/, :string, /^(\d\d\d\d)|((100 )?[^\d]+)$/, /^(([^\d]+)|(.+))(2006)?$/, /^(((\d|\.)*\d\d\d)|(\d?\d\d))$/]
    groups = get_text_groups(resource, formats, 'text[@font="0"]') do |xml|
      xml.gsub!(/<text [^>]+>\d+\/174 <\/text>/, '')

      xml.gsub!(/<text ([^>]+)left="94"([^>]+)>(\d\d\d\d) (.+)  (.+) <\/text>/,
        '<text \1left="94"\2>\3 \4</text>
<text \1left="515"\2>\5</text>')
      
      xml.gsub!('Bundesverband privater  Anbieter sozialer Dienste e.V.', 'Bundesverband privater Anbieter sozialer Dienste e.V.')
      
      xml.sub!('<text top="758" left="94" width="112" height="17" font="0">2008 3Lines AG </text>',
'<text top="758" left="94" width="112" height="17" font="0">2008 </text>
<text top="758" left="132" width="112" height="17" font="0">3Lines AG </text>')

      xml.sub!('<text top="608" left="94" width="472" height="17" font="0">2008 Niederrheinische Kreishandwerkerschaft Krefeld-Viersen Krefeld </text>',
'<text top="608" left="94" width="472" height="17" font="0">2008 Niederrheinische Kreishandwerkerschaft Krefeld-Viersen </text>
<text top="608" left="515" width="472" height="17" font="0">Krefeld </text>')

      xml.sub!('<text top="177" left="94" width="455" height="17" font="0">2008 New Horizons Köln Computer Learning Company GmbH Köln </text>',
'<text top="177" left="94" width="455" height="17" font="0">2008 New Horizons Köln Computer Learning Company GmbH</text>
<text top="177" left="515" width="455" height="17" font="0">Köln </text>')
      
      xml.sub!('<text top="645" left="94" width="471" height="17" font="0">2008 MPFA Weimar WEiterbildungszentrum Betonbau Apolda Apolda </text>',
'<text top="645" left="94" width="471" height="17" font="0">2008 MPFA Weimar WEiterbildungszentrum Betonbau Apolda</text>
<text top="645" left="515" width="471" height="17" font="0">Apolda </text>')


      xml.sub!('<text top="552" left="94" width="496" height="17" font="0">2008 Handwerkskammer Düsseldorf -Weiterbildungszentrum- Düsseldorf </text>',
'<text top="552" left="94" width="496" height="17" font="0">2008 Handwerkskammer Düsseldorf -Weiterbildungszentrum- </text>
<text top="552" left="515" width="496" height="17" font="0">Düsseldorf </text>')

      xml.sub!('<text top="589" left="94" width="496" height="17" font="0">2008 Handwerkskammer Düsseldorf Ges. f. Quali. u. Handw  Düsseldorf </text>',
'<text top="589" left="94" width="496" height="17" font="0">2008 Handwerkskammer Düsseldorf Ges. f. Quali. u. Handw</text>
<text top="589" left="515" width="496" height="17" font="0">Düsseldorf </text>')

      xml.sub!('<text top="327" left="94" width="485" height="17" font="0">2008 Gesellschaft für Prozess-, Mess-, und Regeltechnik mbH Duisburg </text>',
'<text top="327" left="94" width="485" height="17" font="0">2008 Gesellschaft für Prozess-, Mess-, und Regeltechnik mbH </text>
<text top="327" left="515" width="485" height="17" font="0">Duisburg </text>')

      xml.gsub!('<text top="477" left="94" width="521" height="17" font="0">2008 Gelsenpflege Ambulante Private Pflegegesellschaft mbH Gelsenkirchen </text>',
'<text top="477" left="94" width="521" height="17" font="0">2008 Gelsenpflege Ambulante Private Pflegegesellschaft mbH </text>
<text top="477" left="515" width="521" height="17" font="0">Gelsenkirchen </text>')

      xml.sub!('<text top="776" left="94" width="38" height="17" font="0">2006 </text>
<text top="776" left="702" width="237" height="17" font="0">Sonderprogramm Ausbildung 2006 </text>
<text top="776" left="1162" width="54" height="17" font="0">8.286  </text>',
'<text top="776" left="94" width="38" height="17" font="0">2006 </text>
<text top="776" left="515" width="70" height="17" font="0">Dortmund </text>
<text top="776" left="702" width="237" height="17" font="0">Sonderprogramm Ausbildung 2006 </text>
<text top="776" left="1162" width="54" height="17" font="0">8.286  </text>')
      
      xml.sub!('<text top="346" left="94" width="38" height="17" font="0">2006 </text>
<text top="346" left="702" width="237" height="17" font="0">Sonderprogramm Ausbildung 2006 </text>
<text top="346" left="1145" width="71" height="17" font="0">123.148  </text>',
'<text top="346" left="94" width="38" height="17" font="0">2006 </text>
<text top="346" left="515" width="111" height="17" font="0">Recklinghausen </text>
<text top="346" left="702" width="237" height="17" font="0">Sonderprogramm Ausbildung 2006 </text>
<text top="346" left="1145" width="71" height="17" font="0">123.148  </text>')
         
      xml.sub!('<text top="514" left="702" width="256" height="17" font="0">Weiterbildung geht zur Schule (MSW) </text>
<text top="514" left="1145" width="71" height="17" font="0">538.494  </text>',
'<text top="514" left="515" width="256" height="17" font="0">Düsseldorf</text>
<text top="514" left="702" width="256" height="17" font="0">Weiterbildung geht zur Schule (MSW) </text>
<text top="514" left="1145" width="71" height="17" font="0">538.494  </text>')
      
      xml.sub!('<text top="645" left="702" width="266" height="17" font="0">Lebens- und erwerbsweltbezogene WB </text>
<text top="664" left="702" width="125" height="17" font="0">(Overhead, MSW) </text>
<text top="664" left="1145" width="71" height="17" font="0">134.759  </text>',
'<text top="645" left="515" width="266" height="17" font="0">Köln</text>
<text top="645" left="702" width="266" height="17" font="0">Lebens- und erwerbsweltbezogene WB </text>
<text top="664" left="702" width="125" height="17" font="0">(Overhead, MSW) </text>
<text top="664" left="1145" width="71" height="17" font="0">134.759  </text>')

      File.open('/Users/x/junk.xml','w') do |f|
        f.write xml
      end
      xml
    end
    

    debug = false
    @projects = []
    by_position(groups) do |group, by_position|
      parts_count = by_position.keys.size
      expected = 5
      if parts_count != expected
        values = by_position.values
        values = values.collect {|x| x.collect(&:value).join(" ").squeeze(' ') }

        if parts_count == 4
          year_match = final_format_match(0,values)
          puts "year_match: #{year_match}" if debug
          city_match = final_format_match(-3,values)
          puts "city_match: #{city_match}" if debug
          desc_match = final_format_match(-2,values)
          puts "desc_match: #{desc_match}" if debug
          amount_match = final_format_match(-1,values)
          puts "amount_match: #{amount_match}" if debug
          
          if amount_match && desc_match && city_match && year_match
            puts "4 parts match" if debug
            puts ""             if debug
            beneficiary = @previous.to_a.sort_by{|x| x[0].to_i}[1]
            by_position[beneficiary[0]] = beneficiary[1]
            parts_count = by_position.keys.size
          end
        end
        if parts_count == 3
          year_match = final_format_match(0,values)
          puts "year_match: #{year_match}" if debug
          desc_match = final_format_match(-2,values)
          puts "desc_match: #{desc_match}" if debug
          amount_match = final_format_match(-1,values)
          puts "amount_match: #{amount_match}" if debug
          if amount_match && desc_match && year_match
            puts "3 parts match" if debug
            puts "" if debug
            beneficiary = @previous.to_a.sort_by{|x| x[0].to_i}[1]
            city = @previous.to_a.sort_by{|x| x[0].to_i}[2]
            by_position[beneficiary[0]] = beneficiary[1]
            by_position[city[0]] = city[1]
            parts_count = by_position.keys.size
          end
        end

        if parts_count != expected
          values = by_position.values
          values = values.collect {|x| x.collect(&:value).join("\n") }
          raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
        end
      end
      @previous = by_position
      add_project(by_position, resource)
    end
  end

  def add_project by_position, resource
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip
      # unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        # raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/] && !value[/TYPO3-Macher|Stadt Lünen|Kreis Euskirchen|Kreis Coesfeld/]
      # end
      project.morph(attribute_keys[index], value)
    end
    project.fund_type = 'ESF'
    project.currency = 'EUR'
    project.uri = resource.uri
    @projects << project
  end

  def attribute_keys
    [
    :jahr_der_bewilligung,
    :name_des_begunstigten,
    :wohnort_des_begunstigten,
    :kurzbeschreibung_des_vorhabens,
    :gewahrte_betrage,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def split_this text
    case text
      when /^(2006)\s(.+)  (.+)$/
        [$1,$2,$3]
      when /^(2007)\s(.+)  (.+)$/
        [$1,$2,$3]
      when /^(2008)\s(.+)  (.+)$/
        [$1,$2,$3]
      when /^(2006)\s(.+)$/
        [$1,$2]
      when /^(2007)\s(.+)$/
        [$1,$2]
      when /^(2008)\s(.+)$/
        [$1,$2]
      when /^(Schloß Holte-Stukenbrock)  (.+)$/
        [$1,$2]
      when /^(.+)  (Bildungsschecks \/Beratungsstellen)$/
        [$1,$2]
      else
        nil
    end
  end

  def ignore_this
    [
      'Begünstigten Verzeichnis - Operationelles Programm des Landes Nordrhein-Westfalen für den Europäischen Sozialfonds -',
      'Förderperiode 2007 - 2013'
    ].inject({}) {|h,x| h[x] = true; h}
  end

end
