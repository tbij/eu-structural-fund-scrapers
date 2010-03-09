require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkYorkshireParse

  include EuCohesion::ParserBase

  def perform result
    @projects = []
    resources = result.scraped_resources
    text = resources.first.contents
    parse text

    write_csv attributes, attribute_keys, 'eu_cohesion/uk_yorkshire.csv'
  end
  
  def parse text
    text.each_line do |line|
      case line
        when /^[A-Z]/
          unless line[/^Last Updated/]
            add_project(line) do |data, project|
              data.gsub!(/(\d) /, '\1  ')
              values_from_line(data)
            end
          end
      end
    end
  end

  def attributes
    ["Name of Beneficiary","Name of Operation","Priority","ERDF Contracted",
    'Public / Private Match Contracted',"ERDF Start Date","ERDF End Date",
    "Status","Variation","New ERDF committed","New Public Match Committed",
    "ERDF Variation Start Date","ERDF Variation End Date"]
  end
  
  def attribute_keys
    [
      :name_of_beneficiary,
      :name_of_operation,
      :priority,
      :erdf_contracted,
      :public_private_match_contracted,
      :erdf_start_date,
      :erdf_end_date,
      :status,
      :variation,
      :new_erdf_committed,
      :new_public_match_committed,
      :erdf_variation_start_date,
      :erdf_variation_end_date
    ]
  end
  
end
