require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItToscanaErdfLinkParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('It toscana erdf scrape')

    resources = result.scraped_resources
    resources = resources.select {|r| r.web_resource.uri[/creo/] }
    
    all = []
    resources.each do |resource|
      links = resource.links.select {|link| link['href'][/elencobeneficiar/] }.collect do |x|
        # [x['href'], x.inner_html.strip, resource.web_resource.uri]
        [x['href'], x.inner_html.strip]
      end

      all += links
    end

    # sorted = all.sort_by{|x| x[0]}
    # y sorted
    # y sorted.size

    # grouped = all.group_by{|x| x[0]}
    # y grouped
    # y grouped.size

    unique = all.uniq.sort

    unique.each do |x|
      puts x.join("\t")
    end
    # write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_toscana_erdf_link.csv'
  end


  
end



