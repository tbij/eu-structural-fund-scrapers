require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeSchleswigHolsteinEsfParse

  include EuCohesion::ParserBase

  def perform result
    resource = result.scraped_resources.first
    parse resource
    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_schleswig_holstein_esf.csv'
  end

  def first_data_value
    'A. Heinemann GmbH and Co. KG'
  end

  def final_format_match offset, values
    text = values[offset]
    text.strip[@formats[offset]]
  end

  IGNORE = ['Verzeichnis der Begünstigten für die Region Schleswig-Holstein',
'letzte Aktualisierung: 31.12.2008',
'Jahr der',
'Bewilligung /',
'Restzahlung',
'Gewährte Beträge',
'Bei Abschluss des',
'Vorhabens gezahlte',
'Gesamtbeträge',
'Name der bzw. des Begünstigten',
'Auszahlung von öffentlichen Mitteln an die Begünstigten',
'(aus ESF-Mitteln und ggf. nationalen öffentlichen Mitteln)',
'Bezeichnung des Vorhabens',
'Seite '
]
  IGNORE_RE = /#{IGNORE.join('|')}/

  def parse resource
    formats = [:string, :string, /^\d\d\d\d$/, /^((\d|\.)*\,\d\d)|$/, /^((\d|\.)*\,\d\d)|$/]
    groups = get_text_groups(resource, formats, 'text[@font="0"]') do |xml|
      xml.gsub!(' &amp; ',' and ')
      xml.gsub!(/<text ([^>]+)>\s+<\/text>/, '')
      
      lines = []
      
      xml.each_line do |line|
        unless line[IGNORE_RE]
          lines << line.strip
        end
      end
      
      xml = lines.join("\n")
      File.open('/Users/x/junk.xml','w') do |f|
        f.write xml
      end
      xml
    end
    
    @projects = []
    by_position(groups) do |group, by_position|
      parts_count = by_position.keys.size
      expected = 5
      if parts_count != expected
        values = by_position.values
        values = values.collect {|x| x.collect(&:value).join("\n") }
        raise "\n#{by_position.keys.inspect}:\n#{group.inspect} -> \n#{by_position.to_yaml}\n#{values.join("\n")}\nexpected #{expected} items, got #{parts_count}\n#{@previous.inspect}"
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
        # raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/] && !value[/Transerv 2000 Service|B3|B4|B5/]
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
    :name_des_begunstigten,
    :bezeichnung_des_vorhabens,
    :jahr_der_bewilligung,
    :gewahrte_betrage,
    :bei_abschluss_des_vorhabens_gezahlte_gesamtbetrage,
    :fund_type,
    :currency,
    :uri
    ]
  end

  def split_this text
    case text
    when /^(\d\d\d\d)\s\s\s*(((\d|\.)*\,\d\d)|-)\s\s\s*(((\d|\.)*\,\d\d)|-)\s*$/
        [$1,$2,$5]
      else
        nil
    end
  end
        
end
