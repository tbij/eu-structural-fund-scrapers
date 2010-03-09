require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::IndexScrape
  include EuCohesion::ScraperBase
  def uri
    "http://ec.europa.eu/regional_policy/country/commu/beneficiaries/scripts/regions_en.js"    
  end
end
