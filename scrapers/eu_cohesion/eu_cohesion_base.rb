module EuCohesion
end

module EuCohesion::ScraperBase

  def perform result
    WebResource.scrape_and_add(uri, result)
  end

end
