module ESearchy  
  class GenericEngine
    
    def initialize(query, start = 0, stop = nil, &block)
      @query = CGI.escape(query) or raise ESearchyMissingQuery
      @company = ESearchy::Search.company || ""
      @start = start
      @totalhits = stop
      @documents = []
      self.class::TYPE < 2 ? @emails = [] : @people = []
      @results = []
      block.call(self) if block_given?
    end
    
    attr_reader :documents
    attr_reader :results
    attr_reader :emails
    attr_reader :people
    
    
    def search
      get self.class::ENGINE, self.class::PORT, 
          @querypath + @start.to_s, header() do |r|
        parse(r.body)
        D "Searching #{self.class} from #{@start} to #{calculate_top()}.\n"
        crawler(r.body.gsub(/<em>|<\/em>/,"").gsub(/<b>|<\/b>/,"")) unless @totalhits == 0
        @start = @start + self.class::NUM
        sleep(4) and search if @totalhits > @start
      end
    end
    
    def start=(v)
      @start=v
    end
        
    def maxhits=(v)
      @totalhits=v
    end
    
    def company=(v)
      @company=v
    end
    
    private
    
    def get(url, port, querystring = "/", headers = {}, &block)
      http = Net::HTTP.new(url,port)
      begin
        http.start do |http|
          request = Net::HTTP::Get.new(querystring, headers)
          response = http.request(request)
          case response
          when Net::HTTPSuccess, Net::HTTPRedirection
            block.call(response)
          else
            return response.error!
          end
        end
      rescue Net::HTTPFatalError
        D "Error: Something went wrong with the HTTP request"
      end
    end
    
    def header
      begin
        return self.class::HEADER
      rescue
        return {'User-Agent' => UserAgent::fetch}
      end
    end
    
    def calculate_top
      (@start+self.class::NUM) > @totalhits ? @totalhits : @start+self.class::NUM
    end
    
    def totalhits(realhits)
      @totalhits > realhits ? realhits : @totalhits
    end
    
    def parse(object)
      case object
      when Array
        parse_html object
      when Json
        parse_json object
      end
    end
    
    def parse_html ( array )
      array.each do |a|
        case a[0]
        when /(PDF|DOC|XLS|PPT|TXT)/
          @documents << [a[1],"."+$1.to_s.downcase]
        when nil
          if a[2] =~ /(.pdf$|.doc$|.docx$|.xlsx$|.pptx$|.odt$|.odp$\
|.ods$|.odb$|.txt$|.rtf$|.ans$|.csv$)/i
            @documents << [a[2],$1.to_s.downcase]
          end
        when /(.pdf$|.doc$|.docx$|.xlsx$|.pptx$|.odt$|.odp$|.ods$|.odb$|.txt$|.rtf$|.ans$|.csv$)/i
          @documents << [CGI.unescape(a[2] || ""),$1.to_s.downcase]
        else
          #D "I do not parse this doc's \"#{a}\" filetype yet:)"
        end
      end
    end
    
    def parse_json ( json )
      json.each do |j|
        case j["url"]
        when /(.pdf$|.doc$|.docx$|.xlsx$|.pptx$|.odt$|.odp$|.ods$|.odb$|.txt$|.rtf$|.ans$|.csv$)/i
          @documents << [j["url"],$1.to_s.downcase]
        else
          @urls << [j["url"],$1.to_s.downcase]
        end
      end
    end
    
    def crawler(text)
      self.class::TYPE < 2 ? crawl_emails(text) : crawl_people(text)
    end
    
    def crawl_emails(text)
      list = text.scan(/[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*_at_\
(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|\
[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*\sat\s(?:[a-z0-9](?:[a-z0-9-]\
*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|[a-z0-9!#$&'*+=?^_`{|}~-]+\
(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|\
[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\.[a-z0-9!#$&'*+=?^_`{|}~-]+)*\s@\s(?:[a-z0-9](?:[a-z0-9-]*\
[a-z0-9])?\.)+[a-z](?:[a-z-]*[a-z])?|[a-z0-9!#$&'*+=?^_`{|}~-]+(?:\sdot\s[a-z0-9!#$&'*+=?^_`\
{|}~-]+)*\sat\s(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\sdot\s)+[a-z](?:[a-z-]*[a-z])??/i)
      #print_(list)
      c_list = fix(list)
      @emails.concat(c_list).uniq!
      c_list.zip do |e| 
        @results << [e[0], "E", self.class.to_s.upcase, 
                     e[0].match(/#{CGI.unescape(@query).gsub("@","").split('.')[0]}/) ? "T" : "F"]
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
    
    def crawl_people(text)
      raise "This is just a container"
    end 
  end
end
