require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::EsAndaluciaErdfParse

  include EuCohesion::ParserBase

  def csv_name
    'eu_cohesion/es_andalucia_erdf.csv'
  end

  def perform result
    result = result_from_scraper('Es erdf scrape')
    resources = result.scraped_resources
    uri = 'http://www.dgfc.sgpg.meh.es/aplweb/pdf/DescargasFondosComunitarios/(3027)AN11.pdf'
    resource = resources.detect {|r| r.web_resource.uri == uri}
    parse resource, uri
  end

  def get_text_groups_by_page resource, formats, selector='text', &block
    pdf_text = resource.contents
    plain_pdf_text = resource.plain_pdf_contents
    xml = resource.xml_pdf_contents.gsub(" id="," id_attr=")

    xml = yield xml if block
    doc = Hpricot.XML xml

    pages = (doc/'page')
    texts = pages.collect do |page|
      cells = (page/selector).collect do |text|
        attributes = text.attributes.to_hash
        text = text.inner_text
        make_cell(attributes, text, 0)
      end
      by_top = cells.group_by { |x| x.top.to_i }
      tops = by_top.keys.sort
      tops.collect do |top|
        cells = by_top[top].sort_by { |x| x.left.to_i }
      end.flatten
    end.flatten
    
    write_out_csv('texts.csv') {|csv| texts.each {|t| csv << t.value if t.value } }

    @groups = []
    @stack = []
    @formats = formats
    texts.each do |text|
      if has_string_value?(text)
        @stack << text unless ignore_this[text.value.strip]
      else
        $stderr.write text.inspect
      end
      if format_match(-1) && format_match(-2) && format_match(-3)
        top_of_end_cell = @stack.last.top.to_i
        while !(@stack.first.top.to_i == top_of_end_cell) && !( (@stack.first.top.to_i - 1) == top_of_end_cell) && !( (@stack.first.top.to_i + 1) == top_of_end_cell)
          belongs_to_previous = @stack.delete_at(0)
          @groups.last << belongs_to_previous
        end
        @groups << @stack
        @stack = []
      end
    end
    
    @groups = @groups.collect do |group|
      by_left = group.group_by(&:left)
      by_left.collect do |left, cells|
        if cells.size > 1
          cell = cells.delete_at(0)
          start_value = cell.value
          other_values = cells.collect(&:value)
          cell.value = "#{start_value} #{other_values.join(' ')}".squeeze(' ').strip
          cell
        else
          cells.first
        end
      end
    end

    write_out_csv('groups.csv') {|csv| @groups.each {|g| csv << '===' ; csv << g.collect(&:value) } }
    @groups
  end

  def parse resource, uri
    formats = [:string, :string, /^(\d|\.)*\,\d\d$/, /^(\d|\.)*\,\d\d$/, /^\d\d\d\d$/]
    groups = get_text_groups_by_page(resource, formats, 'text[@font="6"]') do |xml|
      xml.gsub!(/^.+Programa Operativo.+$/,'')
      xml
    end
    @projects = []

    groups.each_with_index do |group, index|
      if group.size == 4 && groups[index - 1].size == 5
        group.insert(0, groups[index - 1].first)
      end
      if group.size != 5
        raise group.inspect
      end
      
      add_project group, attribute_keys do |data, project|
        data.collect(&:value) + [uri]
      end
    end
    
    write_csv attribute_keys, attribute_keys, csv_name, [:montante_concedido, :montante_pagado_final_operacion]
  end

  def attribute_keys
    [
    :nombre_beneficiario,
    :nombre_operacion,
    :montante_concedido,
    :montante_pagado_final_operacion,
    :ano_de_la_concesion_ano_del_pago,
    :uri
    ]
  end
  
end
