require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base.rb')

class EuCohesion::UkWestMidlandsScrape
  include EuCohesion::ScraperBase
  def uri
    "http://www.advantagewm.co.uk/Images/ERDF%20Beneficiaries_tcm9-16686.pdf"
  end
end
