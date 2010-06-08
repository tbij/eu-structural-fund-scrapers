require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItToscanaErdfParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    resources = resources.select {|r| !r.web_resource.uri[/creo/] }

    resources.each do |resource|
      @projects = []
      parse resource
      # write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_toscana_erdf_link.csv'
    end
  end
  
  def parse resource
    formats = [:string, :string, /.+/, /^(\d|\.)+\d$/, /^(\d|\.)+\d$/]
    groups = get_text_groups(resource, formats, 'text[@font="'+font_number+'"]')

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 5
        log_by_position by_position, group
      end
      add_project(by_position, resource)
    end
  end


  
end



