require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItFriuliVeneziaGiuliaEsfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    @projects = []
    parse resources.first.contents
    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_friuli_venezia_giulia_esf.csv'
  end

  def parse text
    text.gsub!(/([^\s])\s\s+\*/, '\1 *')
    text.gsub!(/\s*\*\sGli importi esposti comprendono tutte e soltanto le quote di finanziamento pubblico\s+\d+\s*$/, '')
    
    text.sub!('MANUT. HARDWARE/SOFTWARE P.C.                   - 17040148','MANUT. HARDWARE/SOFTWARE P.C. - 17040148')

    text.sub!(%Q|AZIENDA TERRITORIALE PER L'EDILIZIA RESIDENZIALE DELLA                                                  LE NUOVE NORME DELLA SICUREZZA IN AZIENDA E NEI CANTIERI
                                                          1       A            4         200814200001                                                               2008   4.209,28           4.209,28
PROVINCIA DI GORIZIA                                                                                    TEMPORANEI E MOBILI
AZIENDA TERRITORIALE PER L'EDILIZIA RESIDENZIALE DELLA
                                                          1       A            4         200811555001   USO AVANZATO DEI DATABASE                                   2008   4.271,18           4.271,18
PROVINCIA DI TRIESTE
AZIENDA TERRITORIALE PER L'EDILIZIA RESIDENZIALE DELLA
                                                          1       A            4         200811555002   USO AVANZATO DEI DATABASE                                   2008   4.271,18           4.271,18
PROVINCIA DI TRIESTE|,
%Q|AZIENDA TERRITORIALE PER L'EDILIZIA RESIDENZIALE DELLA PROVINCIA DI GORIZIA   1       A            4         200814200001   LE NUOVE NORME DELLA SICUREZZA IN AZIENDA E NEI CANTIERI TEMPORANEI E MOBILI   2008   4.209,28           4.209,28
AZIENDA TERRITORIALE PER L'EDILIZIA RESIDENZIALE DELLA PROVINCIA DI TRIESTE      1       A            4         200811555001   USO AVANZATO DEI DATABASE                                   2008   4.271,18           4.271,18
AZIENDA TERRITORIALE PER L'EDILIZIA RESIDENZIALE DELLA PROVINCIA DI TRIESTE      1       A            4         200811555002   USO AVANZATO DEI DATABASE                                   2008   4.271,18           4.271,18|)
    
    text.sub!('BUSDON FABIO                                              6       3                      200988888001                                                               2009   8.112,00           6.863,24',
      'BUSDON FABIO                                              6       3         n/a           200988888001                                                               2009   8.112,00           6.863,24')

    text.sub!(%Q|CENTRO FORMAZIONE PROFESSIONALE CIVIDALE SOCIETA'                                                   I SISTEMI PRODUTTIVI: USO DEI MACCHINARI, CONTROLLO
                                                          1       C         111      200935941001                                                               2009   6.480,00           -
COOPERATIVA SOCIALE                                                                                 LAVORAZIONI E GESTIONE LOGISTICA|,
%Q|                                                   I SISTEMI PRODUTTIVI: USO DEI MACCHINARI, CONTROLLO
CENTRO FORMAZIONE PROFESSIONALE CIVIDALE SOCIETA' COOPERATIVA SOCIALE   1       C         111      200935941001                                                               2009   6.480,00           -
                                                                                 LAVORAZIONI E GESTIONE LOGISTICA|)
    
                                                                               
    text.sub!('PROGETTAZIONE 3D DI PARTI MECCANICHE COMPLESSE (SOLIDWORKS) 2008', 'PROGETTAZIONE 3D DI PARTI MECCANICHE COMPLESSE (SOLIDWORKS)    2008')
    text.sub!('COMITATO REGIONALE DELL E.N.F.A.P. DEL FRIULI VENEZIA GIULIA 2', 'COMITATO REGIONALE DELL E.N.F.A.P. DEL FRIULI VENEZIA GIULIA   2')
    
    text.gsub!('GIULIA 4', 'GIULIA   4')
    text.gsub!('GESTIONE AZIENDALE 2009','GESTIONE AZIENDALE   2009')
    text.gsub!('TELEMATICA E RETI 2008', 'TELEMATICA E RETI   2008')
    text.gsub!('GESTIONE AZIENDALE 2008', 'GESTIONE AZIENDALE   2008')
    text.gsub!('ED A 2008','ED A   2008')

    
    text.gsub!('* 2009','*   2009')
    
    @join_to_title = false
    @join_to_beneficiary = false
    @double_value = nil
    @single_value = nil

    text.each_line do |line|
      if line[/^.+([A-Z]|')\s\d\d\d\d\s.+((\d|\.)*\,\d\d).+$/] && !line[/\s\s\d\d\d\d\s/]
        line = line.sub(/([A-Z]|')\s(\d\d\d\d)\s/,'\1   \2 ')
      end

      values = values_from_line(line)
      if values.size == 1
        if @join_to_title
          @projects.last.titolo_operazione = "#{@projects.last.titolo_operazione} #{values.first}"
          @join_to_title = false
        elsif @join_to_beneficiary
          @projects.last.beneficiario = "#{@projects.last.beneficiario} #{values.first}"
          @join_to_beneficiary = false
        else
          @single_value = values.first
        end
      end

      if values.size == 2
        if @join_to_beneficiary
          @projects.last.beneficiario = "#{@projects.last.beneficiario} #{values.first}"
          @projects.last.titolo_operazione = "#{@projects.last.titolo_operazione} #{values.last}"
          @join_to_title = false
          @join_to_beneficiary = false
        else
          @double_value = values
        end
      end
      
      if line[/^.+\d\d\d\d.+((\d|\.)*\,\d\d).+$/]
        if values.size == 8
          if values.first[/^\d+$/]
            values.insert(0, @single_value)
            @join_to_beneficiary = true
          else
            values.insert(5, @single_value)
            @join_to_title = true
          end
          @single_value = nil
        end

        if values.size == 7 && @double_value
          values.insert(0, @double_value.first)
          values.insert(5, @double_value.last)
          @double_value = nil
          @join_to_beneficiary = true
        end

        if values.size == 9
          add_project(line, attribute_keys) {|data, project| values}
        else
          raise "expected 9, got #{values.size}:\n#{values.join("\n")}"
        end
      end
    end
  end
  

  def attribute_keys
    [
    :beneficiario,
    :asse,
    :ob_spec,
    :azione,
    :codice_operazione,
    :titolo_operazione,
    :anno,
    :importo_impegnato, 
    :importo_pagato
    ]
  end

end
