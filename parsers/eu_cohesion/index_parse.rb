require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::IndexParse

  def perform result
    resources = result.scraped_resources
    resource = resources.select { |r| r.git_path[/regions_en/] }.first
    text = resource.contents

    write_html text
    write_csv text
  end
  
  def write_csv text
    country = nil

    output = FasterCSV.generate do |csv|
      csv << ['country','region','uri','google_translate_uri']
      text.each_line do |line|
        case line
          when /^\/\/\d+(.+)$/
            value = $1.strip
            country = value unless value[/SEPERATOR|EUROPE|SEPARATOR/]
          when /no regions available/
            # ignore
          when /^new Array\("([^"]+)", "([^"]+)"\)/
            region = $1
            uri = $2
            uri.sub!('..','http://ec.europa.eu/regional_policy/country/commu/beneficiaries/')
            csv << [translate_uri(uri, country)] unless uri == '#'
        end
      end
    end
    GitRepo.write_parsed 'eu_cohesion/index.csv', output
  end
  
  def translate_uri uri, country
    language = language(country)
    "http://translate.google.com/translate?hl=en&sl=#{language}&tl=en&u=#{uri}"
  end
  
  def language country
    case country
    when 'AUSTRIA'
      'de'
    when 'BELGIUM'
      'fr'
    when 'BULGARIA'
      'bg'
    when 'CYPRUS'
      'el'
    when 'CZECH REPUBLIC'
      'cs'
    when 'DENMARK'
      'da'
    when 'ESTONIA'
      'et'
    when 'FINLAND'
      'fi'
    when 'FRANCE'
      'fr'
    when 'GERMANY'
      'de'
    when 'GREECE'
      'el'
    when 'HUNGARY'
      'hu'
    when 'IRELAND'
      'en'
    when 'ITALY'
      'it'
    when 'LATVIA'
      'lv'
    when 'LITHUANIA'
      'lt'
    when 'LUXEMBOURG'
      'fr'
    when 'MALTA'
      'en'
    when 'NETHERLANDS'
      'nl'
    when 'POLAND'
      'pl'
    when 'PORTUGAL'
      'pt'
    when 'ROMANIA'
      'ro'
    when 'SLOVAKIA'
      'sk'
    when 'SLOVENIA'
      'sl'
    when 'SPAIN'
      'es'
    when 'SWEDEN'
      'sv'
    when 'UK'
      'en'
    else
      raise "unknown language for: #{country}"
    end
  end

  def write_html text
    html = []
    text.each_line do |line|
      case line
        when /^\/\/\d+(.+)$/
          name = $1.strip
          html << "<h2>#{name}</h2>" unless name[/SEPERATOR|EUROPE|SEPARATOR/]
        when /^new Array\("([^"]+)", "([^"]+)"\),/
          name = $1
          uri = $2
          uri.sub!('..','http://ec.europa.eu/regional_policy/country/commu/beneficiaries/')
          html << %Q|<p><a href="#{uri}">#{name}</a></p>|
      end
    end
    GitRepo.write_parsed 'eu_cohesion/index.html', html.join("\n")
  end
  
end
