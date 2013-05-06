require 'nokogiri'
require 'open-uri'
require 'openssl'


 
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class LuckasParser

  def initialize(baseURL, user, password, divclass, destination)
    @doc = Nokogiri::HTML(open(baseURL))
    @user = user
    @password = password
    @div = "div."+divclass+" a"
    @destination = destination
  end

  def download( url)
    file_name = url.split('/').last
  
    if not File.exist?(@destination+file_name)
      puts file_name
      open(@destination+file_name, 'wb') do |file|
        file << open( url ,  :http_basic_authentication=>[@user, @password]).read
      end
    end
  end

  def runParser
    threads = []
    @doc.css(@div).each do |link|
      full_url  = link['href']  
      threads << Thread.new{ self.download(full_url) }
    end
    threads.each do |thread|
      thread.join
    end
  end

  

end



if __FILE__ == $0
  url = "http://www.fh-bingen.de/lehrende/luckas-volker/prof-dr-volker-luckas/vorlesungen/sommersemester-2013/mmi1.html"
  user = "mmi1"
  pwd = ""
  div ="csc-textpic-text"
  dest =""
  lck = LuckasParser.new( url , user , pwd , div , dest)
  th =Thread.new{ lck.runParser }
  th.join
end

