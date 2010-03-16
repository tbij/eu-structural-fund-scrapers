require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::DeHamburgEfreParse

  include EuCohesion::ParserBase

  def perform result
    resources = result.scraped_resources
    resource = resources.detect {|r| r.web_resource.uri == 'http://www.hamburg.de/contentblob/1624550/data/efre-beguenstigte.pdf'}
    parse resource
  end
  
  def parse resource
    formats = [:string, :string, /^\d\d\d\d$/, /^(\d|\.)+\sEuro$/, /^(((\d|\.)+\sEuro)|)$/]
    groups = get_text_groups(resource, formats, 'text[@font="9"]')
    @projects = []

    by_position(groups) do |group, by_position|
      if by_position.keys.size != 5
        raise by_position.keys.inspect + ': ' + group.inspect + ' -> ' + by_position.inspect
      end

      project = EuCohesion::Project.new
      by_position.keys.sort.each_with_index do |key, index|
        value = by_position[key].collect(&:value).join(' ').squeeze(' ').chomp(' !').strip
        # unless @pdf_text.include?(value) || @plain_pdf_text.include?(value)
          # raise "#{value} not found in pdf text" unless value[/Produktion von Software/]
        # end
        project.morph(attribute_keys[index], value)
      end
      project.fund_type = 'EFRE'
      project.currency = 'EUR'
      project.uri = resource.uri
      @projects << project
    end

    write_csv attribute_keys, attribute_keys, 'eu_cohesion/de_hamburg_efre.csv'
  end

  def attribute_keys
    [
    :name_des_begunstigten,
    :bezeichnung_des_vorhabens,
    :jahr_der_bewilligung,
    :bewilligter_betrag,
    :ausgezahlter_betrag_zum_vorhabenabschluss,
    :fund_type,
    :currency,
    :uri
    ]
  end
  
  def first_data_value 
    'Rolf Gleich'
  end

  def split_this text
    nil
    # if text[/^(\d\d\.\d\d\.\d\d) (\d\d\.\d\d\.\d\d)$/]
      # [$1, $2]
    # else
      # nil
    # end
  end

  def ignore_this
    {
      # 'Verzeichnis der Begünstigten' => true,
      # 'Stand Januar 2010' => true
    }
  end
  
end
