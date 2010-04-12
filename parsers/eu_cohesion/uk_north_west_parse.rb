require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkNorthWestParse

  include EuCohesion::ParserBase

  def perform result
    @projects = []
    resources = result.scraped_resources
    doc = resources.first.hpricot_doc
    tables = (doc.at('.CmsContentPanels') / 'table')
    
    tables.each_with_index do |table, index|
      parse_table table, index
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/uk_north_west_erdf.csv'
  end
  
  def parse_table table, index
    priority = table.previous_sibling.inner_text
    first = true
    attributes = nil
    (table/'tr').each do |row|
      if first
        attributes = (row/'td').collect {|x| x.inner_text}
        puts attributes.inspect
        first = false
      else
        add_project(row, attributes) do |data, project|
          project.priority = priority
          values = (data/'td').collect {|x| x.inner_text}
        end
      end
    end
  end
  
  def attribute_keys
    [
    :priority,
    :name_of_beneficiary_organisation,
    :name_of_the_project,
    :erdf_amount_committed,
    :other_public_funding_committed,
    :total_committed,
    :other_public_funding_allocated,
    :total_amount_paid_at_the_end_of_the_project
    ]
  end
  
end
