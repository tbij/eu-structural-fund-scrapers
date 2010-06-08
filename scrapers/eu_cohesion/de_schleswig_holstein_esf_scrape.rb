require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeSchleswigHolsteinEsfScrape
  include EuCohesion::ScraperBase
  def perform result
    uri = 'http://www.ib-sh.de/fileadmin/ibank/Zukunftsprogramm/vdb_20081231.pdf'
    WebResource.scrape_and_add(uri, result)
  end
end
