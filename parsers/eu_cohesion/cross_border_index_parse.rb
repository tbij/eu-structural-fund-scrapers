require File.expand_path(File.dirname(__FILE__) + '/index_parse')

class EuCohesion::CrossBorderIndexParse < EuCohesion::IndexParse

  def perform result
    resources = result.scraped_resources
    resource = resources.select { |r| r.git_path[/crossborder/] }.first
    text = resource.contents
    name = 'eu_cohesion/cross_border_index.csv'
    write_csv text, name
  end
  
end
