#! /usr/local/opt/ruby/bin

require 'nokogiri'
require 'digest'
require 'open-uri'
require 'openssl'
require 'yaml'
require 'timeout'



OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE


class UnivLoader

  def initialize(baseURL, user, password, destination, css_Filter, file_Filter, relative_Path)
    @threaded = true
    @user = user
    @password = password
    @css = css_Filter
    @destination = destination
    @allowed_Files = file_Filter
    @relative_Path = relative_Path
    if not File.exist?(@destination)
      make_Dest
    end
    if relative_Path
      @baseURL = baseURL.split("/")
    end
    @doc = Nokogiri::HTML(open(baseURL, :http_basic_authentication => [@user, @password]))

  end

  def make_Dest # TO DO!
    Dir.mkdir(@destination)
  end


  def checkIfFileAlreadyExists(url)
    file_name = url.split('/').last
    if not File.exist?(@destination+file_name)
      self.download(url, file_name)
      return true
    end
    tempFile = open(url, :http_basic_authentication => [@user, @password]).read
    if not Digest::MD5.hexdigest(File.read(@destination+file_name)) == Digest::MD5.hexdigest(tempFile)
      self.update(tempFile, file_name)
    end
  end

  def update(tempFile, file_name)
    puts "Updating " + file_name
    open(@destination+file_name, 'wb') do |file|
      file << tempFile
      file.close
    end
  end

  def download(url, file_name)
    puts "Downloading " + file_name
    open(@destination+file_name, 'wb') do |file|
      file << open(url, :http_basic_authentication => [@user, @password]).read
      file.close
    end
  end

  def runParser
    threads = []
    @doc.css(@css +" a").each do |link|
      full_url = link['href']

      if @threaded
        fork do
          self.makePath(full_url)
        end
      else
        self.makePath(full_url)
      end

    end
  end

  def makePath(url)
    if not @relative_Path
      self.checkFileType(url)
    else
      i = 0
      catURL =""
      while i < @baseURL.size-1
        catURL += @baseURL[i]+"/"
        i += 1
      end
      catURL += url
      catURL.gsub!(' ', '%20')
      self.checkFileType(catURL)
    end
  end

  def checkFileType(url)
    if @allowed_Files
      type = url.split('.').last
      if @allowed_Files.include?(type)
        self.checkIfFileAlreadyExists(url)
      end
    else
      self.checkIfFileAlreadyExists(url)
    end

  end



end

if __FILE__ == $0
  def load(modul)
    parser= UnivLoader.new(modul[1]["url"], modul[1]["user"], modul[1]["password"],modul[1]["destination"], modul[1]["css-Filter"], modul[1]["fileType-Filter"],  modul[1]["relative_Path"])
    parser.runParser
  end


  modules = YAML.load_file('config.yml')
  pids = []
  modules.each do |modul|
    pids << fork do
      puts "Running " + modul[0]
      load(modul)
    end
  end
  pids.each do |pid|
    Process.wait(pid)
  end
end
