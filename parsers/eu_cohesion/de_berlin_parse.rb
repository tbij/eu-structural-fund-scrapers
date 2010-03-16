require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeBerlinParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    resource = resources.first
    parse resource
  end
  
  def parse resource
    formats = [:string, :string, /^\d\d\.\d\d\.\d\d\d\d$/, /^(\d|\.)*\,\d\d$/, /^(\d|\.)*\,\d\d$/]    
    groups = get_text_groups(resource, formats)
    first_values = values_at_position groups, 0
    @projects = []

    groups.each do |group|
      project = EuCohesion::Project.new
      by_position = group.group_by {|x| x.left.to_i }

      if by_position.keys.size == 4
        by_position.keys.inspect + ': ' + group.inspect + ' -> ' + by_position.inspect
        first_value = group.first.value
        first_values.each do |value|
          if first_value[/^#{value} (.+)$/]
            text = group.first
            text.value = value
            cell = make_cell text.morph_attributes, $1, 1
            group.insert(1, cell)
          end
        end
        by_position = group.group_by {|x| x.left.to_i }
      end

      if by_position.keys.size != 5
        raise by_position.keys.inspect + ': ' + group.inspect + ' -> ' + by_position.inspect
      end

      project = EuCohesion::Project.new
      by_position.keys.sort.each_with_index do |key, index|
        value = by_position[key].collect(&:value).join(' ').squeeze(' ')
        unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
          if value[/\d\d\.\d\d\.\d\d\d\d/]
            raise "#{value} not found in pdf text"
          end
        end
        project.morph(attribute_keys[index], value)
      end
      @projects << project
    end
    
    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_berlin.csv'
  end

  def first_data_value 
    '1. Frauenfußball Verein Spandau e.V.'
  end

  def ignore_this
    {
      'Begünstigtenverzeichnis der Operationellen Programms des EFRE in Berlin 2007-2013 (Stand 31.12.2008)' => true
    }
  end

  def split_this
    {
      'Brunennviertel 20.02.2008' =>
        ['Brunennviertel',
        '20.02.2008'],
      'Migrationshintergrund... 29.07.2008' =>
        ['Migrationshintergrund...',
        '29.07.2008'],
      'Wohnumfeld/BewohnerNetz 23.06.2008' =>
        ['Wohnumfeld/BewohnerNetz',
        '23.06.2008'],
      'Nürtingen-Grundschule 29.11.2007' => 
        ['Nürtingen-Grundschule',
        '29.11.2007'],
      'BA Pankow, Abt. FPU, Amt für Umwelt und Natur Neubau eines Spielplatz (5.Bauabschnitt)' =>
        ['BA Pankow, Abt. FPU, Amt für Umwelt und Natur',
        'Neubau eines Spielplatz (5.Bauabschnitt)'],
      'BA Pankow, Abt. FPU, Amt für Umwelt und Natur Spielplatz Rykestr. 20 Neubau Erweiterung auf Nr. 21' =>
        ['BA Pankow, Abt. FPU, Amt für Umwelt und Natur',
        'Spielplatz Rykestr. 20 Neubau Erweiterung auf Nr. 21'],
      'BA Pankow, Abt. FPU, Amt für Umwelt und Natur Aufwertung Spielplatz Metzer Str. 29' =>
        ['BA Pankow, Abt. FPU, Amt für Umwelt und Natur',
        'Aufwertung Spielplatz Metzer Str. 29'],
      'Bosch Communication Center MagdeburgGmbH Errichtung einer Betriebsstätte' => 
        ['Bosch Communication Center Magdeburg GmbH',
        'Errichtung einer Betriebsstätte'],
      'Büro für Stadtteilnahe Sozialplanung - bfss GmbH Mieterberatung' => 
        ['Büro für Stadtteilnahe Sozialplanung - bfss GmbH',
        'Mieterberatung'],
      'Fachhochschule für Technik und Wirtschaft Berlin POSEIDON 1' =>
        ['Fachhochschule für Technik und Wirtschaft Berlin',
        'POSEIDON 1'],
      'Lüth & Dümchen-Automatisierungs-projekt GmbH Pick by Picture' =>
        ['Lüth & Dümchen-Automatisierungs-projekt GmbH',
        'Pick by Picture'],
      'telea management und und kommunikation gmbh Stärkung des Schulstandortes Gropiusstadt' =>
        ['telea management und und kommunikation gmbh',
        'Stärkung des Schulstandortes Gropiusstadt'],
      'UNIONHILFSWERK Sozialeinrichtungen gGmbH Kindertagesstätte Neukölln, Weserstraße 185, 12045 Berlin' =>
        ['UNIONHILFSWERK Sozialeinrichtungen gGmbH',
        'Kindertagesstätte Neukölln, Weserstraße 185, 12045 Berlin']
    }
  end

  def attribute_keys
    [
    :begunstigter,
    :projekt, 
    :datum_erstbewilligung, 
    :bewilligung_offentlicher, 
    :gesamtauszahlungsbetrag
    ]
  end
  
end
