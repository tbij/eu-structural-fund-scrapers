require File.expand_path(File.dirname(__FILE__) + '/eu_cohesion_base')

class EuCohesion::GrScrape
  include EuCohesion::ScraperBase
  def perform result
    [
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=313', # Environment - Sustainable Development
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=314', # Enhancing Accessibility
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=315', # Entrepreneurship and Competitiveness
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=316', # Digital Convergence
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=360', # Human Resources Development
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=347', # Education and Lifelong Learning
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=358', # Administrative Reform
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=320', # Technical Assistance
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=343', # Macedonia - Thrace
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=361', # Western Greece - Peloponnesus - Ionian Islands
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=337', # Crete and the Aegean Islands
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=362', # Thessalia-Central Greece-Epirus
'http://www.espa.gr/Shared/Download.aspx?cat=attachments&type=Documents&fileid=325'  # Attica
    ].each do |uri|
        WebResource.scrape_and_add(uri, result)
    end    
  end
end
