module EuCohesion
end

module EuCohesion::ScraperBase

  def perform result
    resource = WebResource.scrape(uri, result)
    result.add_resource resource
  end

end
