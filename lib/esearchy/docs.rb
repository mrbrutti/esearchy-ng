module ESearchy
  class PageTextReceiver
     attr_accessor :content

     def initialize
       @content = []
     end

     # Called when page parsing starts
     def begin_page(arg = nil)
       @content << ""
     end

     # record text that is drawn on the page
     def show_text(string, *params)
       @content.last << string.strip
     end

     # there's a few text callbacks, so make sure we process them all
     alias :super_show_text :show_text
     alias :move_to_next_line_and_show_text :show_text
     alias :set_spacing_next_line_show_text :show_text

     # this final text callback takes slightly different arguments
     def show_text_with_positioning(*params)
       params = params.first
       params.each { |str| show_text(str) if str.kind_of?(String)}
     end
  end
  
  class Docs
    case RUBY_PLATFORM 
    when /mingw|mswin/
      TEMP = "C:\\WINDOWS\\Temp\\"
    else
      TEMP = "/tmp/"
    end
    attr_reader :documents, :emails, :results
    
    def initialize(doc=nil, size = 10485760)
      case doc
      when Array
        @@documents = Queue.new
        self.merge doc
      else
        @@documents = doc || Queue.new
      end
      @size = size
      @emails = []
      @results = []
      @lock = Mutex.new
    end
  
    ## Class methods
    def self.search(doc)
      self.new(doc)
      search(doc)
    end
    
    def merge(array)
      array.each {|a| push(a) }
    end
        
    def self.push(doc)
      push(doc)
    end
    
    def push(doc)
      @@documents.push(doc)
    end
  
   def local_search
     threads = []
     while @documents.size >=1
       threads << Thread.new do
         doc = @@documents.pop
         detect_type(doc.split(".")[-1], doc)
       end
       threads.each {|t| t.join } if @threads != nil
     end
   end
  
    def search
      threads = []
      while @@documents.size >=1
        threads << Thread.new do
          document = @@documents.pop
          url = document[0].gsub(' ','+')
          format = document[1]
          if data = download(url)
            name = save_to_disk(url, format, data)
            detect_type(format,name)
            remove_from_disk(name)
          end
        end
        threads.each {|t| t.join } if threads != nil
      end
    end
  
    private
  
    def detect_type(format,name)
      case format
      when /.pdf/
        pdf(name)
      when /.doc/
        doc(name)
      when /txt|rtf|ans/
        plain(name)
      when /.docx|.xlsx|.pptx|.odt|.odp|.ods|.odb/
        xml(name)
      else
        D "Error: Not currently parsing #{format}"
      end
    end
  
    def download(doc)
      web = URI.parse(doc)
      begin
        http = Net::HTTP.new(web.host,80)
        http.start do |http|
          request = Net::HTTP::Head.new("#{web.path}#{web.query}")
          response = http.request(request)
          if response.content_length < @size
            D "Downloading document: #{web.to_s}\n"
            request = Net::HTTP::Get.new("#{web.path}#{web.query}")
            response = http.request(request)
            case response
            when Net::HTTPSuccess, Net::HTTPRedirection
              return response.body
            else
              return response.error!
            end
          else
            D "Debug: Skipping #{web.to_s}. bigger than 10MB.\n"
          end
        end
      rescue Net::HTTPFatalError
        D "Error: HTTPFatalError - Unable to download.\n"
      rescue Net::HTTPServerException
        D "Error: Not longer there. 404 Not Found.\n"
      rescue
        D "Error: < .. SocketError .. >\n"
      end
      nil
    end

    def save_to_disk(url, format, data)
      name = TEMP + "#{hash_url(url)}" + format
      open(name, "wb") { |file| file.write(data) }
      name
    end
    
    def remove_from_disk(name)
      `rm "#{name}"`
    end
    
    def hash_url(url)
      Digest::SHA2.hexdigest("#{Time.now.to_f}--#{url}")
    end
    
    def pdf(name)
      begin
        receiver = PageTextReceiver.new
        pdf = PDF::Reader.file(name, receiver)
        search_emails(receiver.content.inspect)
      rescue PDF::Reader::UnsupportedFeatureError
        D "Error: Encrypted PDF - Unable to parse.\n"
      rescue PDF::Reader::MalformedPDFError
        D "Error: Malformed PDF - Unable to parse.\n"
      rescue
        D "Error: Unknown - Unable to parse.\n"
      end
    end

    def doc(name)
      if RUBY_PLATFORM =~ /mingw|mswin/
        begin
          word(name)
        rescue
          antiword(name)
        end
      elsif RUBY_PLATFORM =~ /linux|darwin/
        begin
          antiword(name)
        rescue
          D "Error: Unable to parse .doc"
        end
      else
        D "Error: Platform not supported."
      end
    end

    def word(name)
      word = WIN32OLE.new('word.application')
      word.documents.open(name)
      word.selection.wholestory
      search_emails(word.selection.text.chomp)
      word.activedocument.close( false )
      word.quit
    end

    def antiword(name)
      case RUBY_PLATFORM
      when /mingw|mswin/
        if File.exists?("C:\\antiword\\antiword.exe")
          search_emails(`C:\\antiword\\antiword.exe "#{name}" -f -s`) 
        end
      when /linux|darwin/
        if File.exists?("/usr/bin/antiword") or 
           File.exists?("/usr/local/bin/antiword") or 
           File.exists?("/opt/local/bin/antiword")
          search_emails(`antiword "#{name}" -f -s`) 
        end
      else
         # This G h e t t o but, for now it works on emails 
         # that do not contain Capital letters:)
         D "Debug: Using the Ghetto way."
         search_emails(File.open(name).readlines[0..19].to_s)
      end
    end

    def plain(name)
      search_emails(File.open(name).readlines.to_s)
    end

    def xml(name)
      begin
        Zip::ZipFile.open(name) do |zip|
          text = z.entries.each { |e| zip.file.read(e.name) if e.name =~ /.xml$/}
          search_emails(text)
        end
      rescue
        D "Error: Unable to parse .#{name.scan(/\..[a-z]*$/)}\n"
      end
    end
    
    def search_emails(text)
      list = text.scan(/[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*_at_\
(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|\
[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*\sat\s(?:[a-z0-9](?:[a-z0-9-]\
*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|[a-z0-9!#$&'*+=?^_`{|}~-]+\
(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|\
[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*\s@\s(?:[a-z0-9](?:[a-z0-9-]*\
[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\sdot\s[a-z0-9!#$&'*+=?^_`\
{|}~-]+)*\sat\s(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\sdot\s)+[a-z](?:[a-z-]*[a-z])??/i)
      @lock.synchronize do
        #print_(list)
        c_list = fix(list)
        @emails.concat(c_list).uniq!
        c_list.zip do |e| 
          @results << [e[0], "E", self.class.to_s.upcase, 
           e[0].match(/#{CGI.unescape(ESearchy::Search.query).gsub("@","").split('.')[0]}/) ? "T" : "F"]
        end
      end
    end

    def fix(list)
      list.each do |e|
        e.gsub!(" at ","@")
        e.gsub!("_at_","@")
        e.gsub!(" dot ",".")
        e.gsub!(/[+0-9]{0,3}[0-9()]{3,5}[-]{0,1}[0-9]{3,4}[-]{0,1}[0-9]{3,5}/,"")
      end
    end
  end
end