require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::TransnationalIndexScrape
  include EuCohesion::ScraperBase
  def uri
    "http://ec.europa.eu/regional_policy/country/commu/beneficiaries/scripts/countries_menu_transnational_en.js"
  end
end
