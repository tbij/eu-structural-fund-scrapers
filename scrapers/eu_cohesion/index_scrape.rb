module EuCohesion
end

class EuCohesion::IndexScrape

  def perform result
    uri = "http://ec.europa.eu/regional_policy/country/commu/beneficiaries/index_en.htm"
    resource = WebResource.scrape(uri, result)    
    result.add_resource resource
    
    uri = "http://ec.europa.eu/regional_policy/country/commu/beneficiaries/scripts/regions_en.js"
    
    resource = WebResource.scrape(uri, result)    
    result.add_resource resource    
  end

end
