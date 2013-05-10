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
    if not File.exist?(destination)
      Dir.mkdir(destination)
    end
  end

  def download( url)
    file_name = url.split('/').last
  
    if not File.exist?(@destination+file_name)
      puts file_name
      open(@destination+file_name, 'wb') do |file|
        file << open( url ,  :http_basic_authentication=>[@user, @password]).read
        file.close
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
  dest =""
  user = "mmi1"
  pwd = ""
  div ="csc-textpic-text"


  lck = LuckasParser.new( url , user , pwd , div , dest)
  th1 =Thread.new{ lck.runParser }
  url = "http://www.fh-bingen.de/lehrende/luckas-volker/prof-dr-volker-luckas/vorlesungen/sommersemester-2013/java3d.html"
  dest =""
  user = "java3d"
  pwd = ""
  lck = LuckasParser.new( url , user , pwd , div , dest)
  th2 =Thread.new{ lck.runParser }
  th1.join
  #th2.join


end

