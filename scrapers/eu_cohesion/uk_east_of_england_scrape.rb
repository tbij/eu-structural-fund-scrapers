require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkEastOfEnglandScrape
  include EuCohesion::ScraperBase
  def uri
    "http://www.eeda.org.uk/files/updated_E_of_E_ERDF_Beneficiaries_List.pdf"
  end
end
