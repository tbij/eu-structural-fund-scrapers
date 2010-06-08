require 'mechanize'
require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::ItEmiliaRomagnaAsseIiErdfScrape
  include EuCohesion::ScraperBase
  def perform result
    uri = 'http://fesr.regione.emilia-romagna.it/allegati/elenco-beneficiari/elelnco-beneficiari-asse-2'
    WebResource.scrape_and_add(uri, result, { :scrape_proc => scrape_proc, :is_pdf => true })
  end
  
  def scrape_proc
    Proc.new { |uri, options, scrape_run_job|
      agent = Mechanize.new do  |a|
        a.user_agent_alias = 'Mac Mozilla'
      end

      agent.get(uri) do |page|
        results = page
        body_file = GitRepo.uri_file_name(uri, results.header['content-type'], results.header['content-disposition'])
        response_file = body_file
        response_text = results.body
        normalized_header = {}
        results.header.each do |key, value|
          key = key.gsub('-','_').to_sym
          normalized_header[key] = value
        end

        response_file = scrape_run_job.pdf_to_text(body_file, response_text)
        response_text = IO.read(response_file)

        scrape_run_job.handle_response_text results.code, results.header, normalized_header, response_text, response_file, body_file, uri
      end
    }
  end
end
