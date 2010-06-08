require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItSiciliaEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    parse resources.first
  end

  NUMBER = /^((\d|\.)+\,\d\d)$/

  IGNORE = []
  IGNORE_RE = /#{IGNORE.join('|')}/

  def parse resource
    formats = [/^.+$/, NUMBER, NUMBER]

    groups = get_text_groups(resource, formats, 'text[@font="3"]') do |xml|      
      xml.sub!('<text top="400" left="985" width="184" height="5" font="3">PIAZZA SEN MARESCALCHI,   €                 43.568,82   €                 43.568,82 </text>',
'<text top="400" left="985" width="184" height="5" font="3">PIAZZA SEN MARESCALCHI</text>
<text top="400" left="985" width="184" height="5" font="3">€                 43.568,82   €                 43.568,82 </text>')

      xml.sub!(%Q|<text top="400" left="985" width="184" height="5" font="3">PIAZZA SEN MARESCALCHI</text>|,
%Q|<text top="400" left="983" width="184" height="5" font="3">PIAZZA SEN MARESCALCHI</text>|)
      
      xml.sub!(%Q|<text top="624" left="985" width="6" height="5" font="3">45</text>|,
%Q|<text top="624" left="984" width="6" height="5" font="3">45</text>|)
      
      xml.sub!(%Q|<text top="196" left="985" width="184" height="5" font="3">CONTRADA PALAMENTANO  €               167.298,67   €               167.298,67 </text>|,
%Q|<text top="196" left="983" width="184" height="5" font="3">CONTRADA PALAMENTANO</text>
<text top="196" left="985" width="184" height="5" font="3">€               167.298,67   €               167.298,67 </text>|)

      xml.sub!(%Q|<text top="485" left="985" width="184" height="5" font="3">Via S. Tommaso D'Aquino, 19  €                 17.536,88   €                 17.536,88 </text>|,
%Q|<text top="485" left="983" width="184" height="5" font="3">Via S. Tommaso D'Aquino, 19</text>
<text top="485" left="985" width="184" height="5" font="3">€                 17.536,88   €                 17.536,88 </text>|)
      
      xml.sub!(%Q|<text top="400" left="248" width="176" height="5" font="3">ALIMENTAZIONE E  G73D06001 I1)1 Attuare strategie preventive contro la </text>|,
%Q|<text top="400" left="246" width="176" height="5" font="3">ALIMENTAZIONE E</text>
<text top="400" left="248" width="176" height="5" font="3">G73D06001</text>
<text top="400" left="250" width="176" height="5" font="3">I1)1 Attuare strategie preventive contro la </text>|)

      xml.sub!('<text top="473" left="1111" width="3" height="5" font="3">  </text>
<text top="473" left="1167" width="3" height="5" font="3">  </text>',
'<text top="473" left="1111" width="3" height="5" font="3"> 0,00  0,00</text>')
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
      add_project(by_position, resource)
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_sicilia_esf.csv'
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
    "2007IT051PO003.4.i1.1"
  end

  def attribute_keys
    [
    :codice_programma,
    :codice_identificativo_operazione,
    :codice_locale_intervento,
    :titolo,
    :cup,
    :fonte_inclusione_rendicontazione,
    :asse,
    :ob_spec,
    :ob_op,
    :denominazione,
    :cf_p_iva,
    :provincia_sede_legale,
    :comune_sede_legale,
    :indirizzo_sede_legale,
    :totale_impegni_beneficiario,
    :totale_pagamenti,
    :fund_type,
    :currency,
    :uri
    ]
  end

  def split_this text
    case text.gsub('€','').strip
    when /^((\d|\.)+,\d\d)\s+((\d|.)+,\d\d)$/
      [$1,$3]
    when /^((\d|\.)+,\d\d)$/
      ['0,00',$1]
    when /^(.+)\s(I1\)1\s.+)$/
      [$1,$2]
    when /^(.+)\s(I2\)\.1.+)$/
      [$1,$2]
    when /^(.+) (\d\d\d\d\d\d\d\d\d\d\d)$/
      [$1,$2]
    else
      nil
    end
  end

end
