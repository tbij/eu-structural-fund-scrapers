require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkNorthWestParse

  def perform result
    @projects = []
    resources = result.scraped_resources
    doc = resources.first.hpricot_doc
    tables = (doc.at('.CmsContentPanels') / 'table')
    
    tables.each_with_index do |table, index|
      parse_table table, index
    end

    write_csv
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
        project = EuCohesion::Project.new
        project.priority = priority
        values = (row/'td').collect {|x| x.inner_text}
        attributes.each_with_index do |attribute, index|
          project.morph(attribute, values[index])
        end
        @projects << project
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
  
  def write_csv
    output = FasterCSV.generate do |csv|
      csv << attribute_keys
      @projects.each do |project|
        csv << attribute_keys.collect { |key| project.send(key) }
      end
    end
    GitRepo.write_parsed 'eu_cohesion/uk_north_west.csv', output
  end
end
