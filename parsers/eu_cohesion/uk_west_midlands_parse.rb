require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::UkWestMidlandsParse

  include EuCohesion::ParserBase

  def perform result
    @projects = []
    resources = result.scraped_resources
    text = resources.first.contents
    parse text

    file = 'eu_cohesion/uk_west_midlands.csv'
    write_csv attributes, attribute_keys, file
  end
  
  def parse text        
    fields = [41,30,12,21,24]
    field_pattern = "a#{fields.join('a')}"
    data = []
    project = EuCohesion::Project.new

    ignore = true
    text.each_line do |line|
      unless ignore || line.blank?
        values = line.gsub(/(\d\.\d)/,' \1').gsub(/\s(\d?\d,)/,'  \1').gsub('–','-').gsub('-','-').gsub('£',' ').unpack(field_pattern).collect {|x| x.gsub("\n",' ').gsub("\f",' ').strip}
        data << values
        if values.first == 'space'
          @projects << project
          project = EuCohesion::Project.new
        else
          values.each_with_index do |value, index|
            if index == 4
              case value
                when /^(.+) AWM$/
                  key = :budget_approved_awm
                  value = $1
                when /^(.+) ERDF$/
                  key = :budget_approved_erdf
                  value = $1
                when /^(.+) PRIVATE$/
                  value = $1
                  key = :budget_approved_private
                when /^((\d|,)+)$/
                  value = $1
                  key = :budget_approved_other_public
                else
                  key = nil
                end
            else
              key = attribute_keys[index]
            end

            if key
              if !project.respond_to?(key) || project.send(key).blank?
                project.morph(key, value) 
              else
                existing = project.send(key)
                unless existing.strip == value.strip
                  project.send("#{key.to_s}=", "#{existing} #{value}")
                end
              end
            end
          end
          
        end
      end
      ignore = false if (ignore && line[/^\s+Date\s+$/])
    end
  end

  def attributes
    ["Project", "Applicant", "Project Approval Date",
    "Priority",
    "Budget Approved AWM",
    "Budget Approved ERDF",
    "Budget Approved Other Public",
    "Budget Approved Private"
    ]
  end
  
  def attribute_keys
    [
    :project,
    :applicant, 
    :project_approval_date, 
    :priority, 
    :budget_approved_awm,
    :budget_approved_erdf,
    :budget_approved_other_public,
    :budget_approved_private
    ]
  end
  
end
