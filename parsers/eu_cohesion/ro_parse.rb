require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::RoParse

  include EuCohesion::ParserBase

  def perform result
    @projects = []
    Dir.glob("#{GitRepo.data_git_dir}/www.fonduri-ue.ro/upload/proiecte_contractate28feb2010.rar/*.pdf").each do |pdf_file|
      text_file = GitRepo.convert_pdf_file pdf_file
      parse pdf_file.gsub(' ','_'), uri='http://www.fonduri-ue.ro/upload/proiecte_contractate28feb2010.rar', '1'
    end

    # write_csv attribute_keys, attribute_keys, 'eu_cohesion/romania.csv'
  end

  def parse pdf_file, uri, font_number
    formats = [:string, /.+/, /^\d\d\d\d$/, /^(\d|\.)*\,\d\d$/]
    pdf_text = GitRepo.read_file(pdf_file.sub(/.pdf$/,'.pdf.txt') )
    plain_pdf_text = GitRepo.read_file(pdf_file.sub(/.pdf$/,'.txt') )
    xml = GitRepo.read_file(pdf_file.sub(/.pdf$/,'.xml') )
    groups = get_text_groups_2 pdf_text, plain_pdf_text, xml, formats, font_number

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 4
        raise by_position.keys.inspect + ': ' + group.inspect + ' -> ' + by_position.to_yaml
      end
      add_project(by_position, uri)
    end
  end

  def add_project by_position, uri
    project = EuCohesion::Project.new
    by_position.keys.sort.each_with_index do |key, index|
      texts = by_position[key]
      value = texts.collect(&:value).join(' ').squeeze(' ').strip
      unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
        raise "#{value} not found in pdf text: #{project.inspect}" if value[/\d/]
      end
      project.morph(attribute_keys[index], value)
    end
    project.fund_type = 'ESF'
    project.currency = 'EUR'
    project.uri = uri
    @projects << project
  end

  def attribute_keys
    [
    :name_des_begunstigten,
    :bezeichnung_des_vorhabens,
    :jahr_bewilligung,
    :gewahrte_betrage,
    # :bei_abschluss_des_vorhabens_gezahlte_gesamtbetrage,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def first_data_value
    @first_data_value
  end

  def split_this text
    case text
      when /^(.+)(Förderprogramm für zusätzliche Ausbildungsplätze)$/
        [$1,'Förderprogramm für zusätzliche Ausbildungsplätze']
      else
        nil
    end
  end

  def ignore_this
    [
      'VERZEICHNIS DER BEGÜNSTIGTEN FÜR BADEN-WÜRTTEMBERG 2008',
      'Auszahlung von öffentlichen Mitteln an die Begünstigten',
      'Name des Begünstigten',
      'Bezeichnung des Vorhabens',
      'Jahr der',
      'Bewilligung /',
      'Restzahlung',
      'Gewährte',
      'Bei Abschluss des',
      'Vorhabens gezahlte',
      'Gesamtbeträge',
      'Vorhaben'
      ].inject({}) {|h,x| h[x] = true; h}
  end
end
