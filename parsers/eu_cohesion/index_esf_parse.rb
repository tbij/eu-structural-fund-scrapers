require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::Region
  include Morph
end

class EuCohesion::IndexEsfParse

  def parse_country c
    region = EuCohesion::Region.new
    region.morph({ :code => c['code'], :country => c.inner_text })
    if c['linkto'][/^http/]
      region.uri = c['linkto']
    else
      region.menu_id = c['linkto']
    end
    region
  end

  def parse_regions doc, regions, country
    (doc/"menu-list##{country.menu_id}/menuitem").each do |r|
      if r['linkto'].blank?
        qualifier = r.inner_text
        (doc/"menu-list##{r['submenu']}/menuitem").each do |s|
          region = EuCohesion::Region.new
          region.morph country.morph_attributes
          region.uri = s['linkto']
          region.name = s.inner_text
          region.qualifier = qualifier
          regions << region
        end
      else
        region = EuCohesion::Region.new
        region.morph country.morph_attributes
        region.uri = r['linkto']
        region.name = r.inner_text
        regions << region
      end
    end
  end
  
  def perform result
    resources = result.scraped_resources
    resource = resources.first
    text = resource.contents
    
    doc = Hpricot.XML text

    countries = (doc/'country').collect do |c|
      parse_country c
    end

    regions = []
    countries.select(&:menu_id).each do |country|
      parse_regions doc, regions, country
    end
    regions = regions.select{|x| !x.uri.blank?} + countries.select{|x| !x.uri.blank?}
    
    regions = regions.sort do |a,b|
      if a.country == b.country
        a.name <=> b.name
      else
        a.country <=> b.country
      end
    end
    name = 'eu_cohesion/index_esf.csv'
    write_csv regions, name
  end
  
  def write_csv regions, file
    output = FasterCSV.generate do |csv|
      csv << ['country','region','uri','google_translate_uri']
      regions.each do |r|
        translated = translate_uri r.uri, r.country
        name = r.qualifier.blank? ? r.name : "#{r.qualifier} - #{r.name}"
        csv << [r.country,name,r.uri,translated]
      end
    end
    GitRepo.write_parsed file, output
  end
  
  def translate_uri uri, country
    language = language(country)
    "http://translate.google.com/translate?hl=en&sl=#{language}&tl=en&u=#{uri}"
  end
  
  def language country
    case country
    when 'Austria'
      'de'
    when 'Belgium'
      'fr'
    when 'Bulgaria'
      'bg'
    when 'Cyprus'
      'el'
    when 'Czech Republic'
      'cs'
    when 'Denmark'
      'da'
    when 'Estonia'
      'et'
    when 'Finland'
      'fi'
    when 'France'
      'fr'
    when 'Germany'
      'de'
    when 'Greece'
      'el'
    when 'Hungary'
      'hu'
    when 'Ireland'
      'en'
    when 'Italy'
      'it'
    when 'Latvia'
      'lv'
    when 'Lithuania'
      'lt'
    when 'Luxembourg'
      'fr'
    when 'Malta'
      'en'
    when 'The Netherlands'
      'nl'
    when 'Poland'
      'pl'
    when 'Portugal'
      'pt'
    when 'Romania'
      'ro'
    when 'Slovakia'
      'sk'
    when 'Slovenia'
      'sl'
    when 'Spain'
      'es'
    when 'Sweden'
      'sv'
    when 'United Kingdom'
      'en'
    else
      raise "unknown language for: #{country}"
    end
  end

end
