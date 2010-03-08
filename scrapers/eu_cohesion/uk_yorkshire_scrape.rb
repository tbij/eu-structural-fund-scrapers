module EuCohesion
end

class EuCohesion::UkYorkshireScrape

  def perform result
    uri = "http://www.yorkshire-forward.com/sites/default/files/documents/Beneficiary%20List%2018-01-10.pdf"
    resource = WebResource.scrape(uri, result)
    result.add_resource resource
  end

end
