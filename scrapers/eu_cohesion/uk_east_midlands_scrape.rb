module EuCohesion
end

class EuCohesion::UkEastMidlandsScrape

  def perform result
    uri = "http://www.eastmidlandserdf.org.uk/index.php?option=com_docman&task=doc_download&gid=256&Itemid=57"
    resource = WebResource.scrape(uri, result)
    result.add_resource resource
  end

end
