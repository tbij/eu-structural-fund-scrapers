module EuCohesion
end

class EuCohesion::UkNorthWestScrape

  def perform result
    uri = "http://www.erdfnw.co.uk/about-us/programme-beneficiaries"
    resource = WebResource.scrape(uri, result)
    result.add_resource resource
  end

end
