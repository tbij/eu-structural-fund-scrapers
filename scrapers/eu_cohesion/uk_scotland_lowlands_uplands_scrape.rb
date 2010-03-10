require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkScotlandLowlandsUplandsScrape
  
  def perform result
    ['http://www.esep.co.uk/assets/files/R2%20awards%20esf.pdf',
    'http://www.esep.co.uk/assets/files/R2%20awards%20erdf.pdf',
    'http://www.esep.co.uk/assets/files/LUPS_ERDF2.pdf',
    'http://www.esep.co.uk/assets/files/LUPS_ESF2.pdf'].each do |uri|
        WebResource.scrape_and_add(uri, result)
    end
  end

end
