require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItCampaniaErdfParse

  include EuCohesion::ParserBase

  def perform result
    resource = result.scraped_resources.first
    @projects = []
    parse resource.contents, resource.uri

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/it_campania_erdf.csv'
  end

  def parse text, uri
    text.each_line do |line|
      values = values_from_line line
      if values.size == 5 && values.last.strip[/^\d\d\d\d$/]
        add_project values, uri
      end
    end
  end

  def add_project values, uri
    project = EuCohesion::Project.new
    values.each_with_index do |value, index|
      attribute = attribute_keys[index]
      project.morph(attribute, value.strip)
    end
    project.fund_type = 'EDRF'
    project.currency = 'EUR'
    project.uri = uri
    @projects << project
  end

  def attribute_keys
    [
    :descrizione_bt,
    :obiettivo_operativo,
    :titolo,
    :costo_totale_intervento,
    :anno_di_assegnazione_dei_fondi,
    # :totale_importo_pagato_alla_fine_del_progetto,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
end



