require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

# part has row, column, value
class EuCohesion::Part
end

class EuCohesion::GrMacedoniaThraceParse

  include EuCohesion::ParserBase

  def perform result
    result = result_from_scraper('Gr scrape')
    resources = result.scraped_resources
    @projects = []
    @numbers = []

    resource = resources.detect {|r| r.web_resource.uri == 'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=343'}

    text = resource.contents
    lines = text.split("\n")

    @entries = []
    handle_lines(lines)

    # write_csv attribute_keys, attribute_keys, 'eu_cohesion/gr_macedonia_thrace.csv'
  end

  def bounds
    [[0,24],[25,94],[95,99],[116,170],176]
  end
  
  def first_value
    'Νοµαρχιακή Αυτοδιοίκηση'
  end

  def handle_lines lines
    results = []
    rows = []
    groups = []
    @start = false
    @new = true
    lines.each do |line|
      line = line.mb_chars
      if line.include?(first_value)
        @start = true
      end
      if @start
        if line.blank?
          groups << rows unless rows.empty?
          rows = []
        else
          # parts = Parser.values_from_line(line).compact
          parts = Parser.values_from_bounds(line,bounds).compact
          items = parts.map { |part| process_part(part, line) }.compact
          results += items
          rows << items
        end
      end
    end
    # groups << rows unless rows.empty?

    Parser.print_column_histogram(results)
    
    entries = groups.collect do |rows|
      columns = perform_split rows
      values = do_join columns
    end
    
    @projects = entries.collect do |values|
      project = EuCohesion::Project.new
      attribute_keys.each_with_index do |key, i|
        project.morph(key, values[i])
      end
      project
    end
    
    write_csv attribute_keys, attribute_keys, 'eu_cohesion/gr_macedonia_thrace.csv'    
  end
  
  def attribute_keys
    [
    :payee_name,
    :project_title,
    :year_joined,
    :public_expenditure_listing,
    :fund
    ]
  end

  def process_part part, line
    [line.index(part), part]
  end
  
  def do_join columns
    values = []
    columns.each do |items|
      value = items.collect { |item| item[1] }.join(' ').squeeze(' ').strip
      values << value
    end
    values
  end

  def perform_split rows
    splits = Array.new(bounds.size) { |i| [] }
    rows.each do |row|
      row.each do |cell|
        x = cell[0]
        set = false
        bounds.each_with_index do |bound, index|
          if bound.is_a?(Array) && (x >= bound.first) && (x <= bound.last)
            splits[index] << cell
            set = true
          elsif !bound.is_a?(Array) && x >= bound
            splits[index] << cell
            set = true
          end
        end
        unless set
          raise cell.inspect
        end
      end
    end
    splits
  end
end
