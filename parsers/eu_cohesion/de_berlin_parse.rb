require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::Receiver
  # def method_missing symbol, *args
    # puts symbol.to_s
  # end
end

class EuCohesion::Cell
  include Morph
end

class EuCohesion::DeBerlinParse

  include EuCohesion::ParserBase

  def has_string_value? text
    text && text.respond_to?(:value) && text.value.is_a?(String)
  end

  def format_match offset
    text = @stack[offset]
    has_string_value?(text) && text.value[@formats[offset]]
  end

  def start_of_data text
    !@started && has_string_value?(text) && (text.value == '1. Frauenfußball Verein Spandau e.V.')
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

  def make_cell attributes, text, delta
    cell = EuCohesion::Cell.new
    cell.morph attributes
    cell.morph('value', text)
    if delta > 0
      cell.left = (cell.left.to_i + delta).to_s
    end
    cell
  end
  
  def get_texts result
    resources = result.scraped_resources
    @pdf_text = resources.first.contents
    @plain_pdf_text = resources.first.plain_pdf_contents
    xml = resources.first.xml_pdf_contents.gsub(" id="," id_attr=")
    doc = Hpricot.XML xml
        
    (doc/'text').collect do |text|
      attributes = text.attributes.to_hash
      text = text.inner_text
      if parts = split_this[text]
        parts.collect { |part| make_cell(attributes, part, parts.index(part)) }
      else
        make_cell(attributes, text, 0)
      end
    end.flatten
  end

  def group_text text
    @started = true if start_of_data(text)
    if @started
      if has_string_value?(text)
        @stack << text unless text.value == 'Begünstigtenverzeichnis der Operationellen Programms des EFRE in Berlin 2007-2013 (Stand 31.12.2008)'
      else
        $stderr.write text.inspect
      end
      if format_match(-1) && format_match(-2) && format_match(-3)
        @groups << @stack
        @stack = []
      end
    end
  end
  
  def perform result
    @formats = [:string, :string, /^\d\d\.\d\d\.\d\d\d\d$/, /^(\d|\.)*\,\d\d$/, /^(\d|\.)*\,\d\d$/]    
    @groups = []
    @stack = []
    @started = false
    texts = get_texts(result)

    output = FasterCSV.generate do |csv|
      texts.each do |text|
        csv << text.value
      end
    end
    File.open('texts.csv','w') {|f| f.write output}

    texts.each do |text|
      group_text text
    end
    
    output = FasterCSV.generate do |csv|
      @groups.each do |texts|
        csv << texts.collect(&:value)
      end
    end
    File.open('groups.csv','w') {|f| f.write output}

    @projects = []
    
    # y @groups
    
    first_values = @groups.collect(&:first).collect(&:value).uniq.collect { |v| v.gsub('+','\+').gsub('(','\(').gsub(')','\)').gsub('[','\[').gsub(']','\]') }

    @groups.each do |group|
      project = EuCohesion::Project.new
      raise group.inspect if group.select{|x|x.is_a?(Hash)}.size > 0

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
    
    
    # puts resources.first.web_resource.file_path
    # puts resources.first.web_resource.file_path
    
    # receiver = EuCohesion::Receiver.new    
    # PDF::Reader.file(resources.first.web_resource.file_path, receiver)

    # parse text
# 
    # y @projects

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_berlin.csv'
  end
  
  def handle_page
  end
  
  def parse text
    text.each_line do |line|
      case line
        when /^[^\s]/
          add_project(line) {|data, project| values_from_line(data)}
      end
    end
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
