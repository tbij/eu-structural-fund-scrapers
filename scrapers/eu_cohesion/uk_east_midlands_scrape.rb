require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkEastMidlandsScrape
  include EuCohesion::ScraperBase
  def uri
    "http://www.eastmidlandserdf.org.uk/index.php?option=com_docman&task=doc_download&gid=256&Itemid=57"
  end
end
