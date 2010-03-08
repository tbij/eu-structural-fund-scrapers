module EuCohesion
end

class EuCohesion::IndexParse

  def perform result
    resources = result.scraped_resources
    resource = resources.select { |r| r.git_path[/regions_en/] }.first
    text = resource.contents

    html = []
    text.each_line do |line|
      case line
        when /^\/\/\d+(.+)$/
          name = $1.strip
          html << "<h2>#{name}</h2>" unless name[/SEPERATOR|EUROPE|SEPARATOR/]
        when /^new Array\("([^"]+)", "([^"]+)"\),/
          name = $1
          uri = $2
          uri.sub!('..','http://ec.europa.eu/regional_policy/country/commu/beneficiaries/')
          html << %Q|<p><a href="#{uri}">#{name}</a></p>|
      end
    end
    GitRepo.write_parsed 'eu_cohesion/index.html', html.join("\n")
  end

end
