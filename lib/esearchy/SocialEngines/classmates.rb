module ESearchy  
  module SocialEngines
    class Classmates < ESearchy::GenericEngine
      ENGINE = "www.google.com"
      PORT  = 80
      NUM = 100
      TYPE = 2
      
      def search 
        @querypath = "/cse?q=site%3Awww.classmates.com+%22work+at+" +  CGI.escape(@company)  +   
                     "%22&hl=en&cof=&num=100&filter=0&safe=off&start=" or raise ESearchyMissingCompany, "Mssing website url Object.company=(value)"
        super
      end
            
      def parse( html )
        hits = html.scan(/<\/b> of[ about | ]<b>(.*)<\/b> from/)
        if hits.empty? or hits == nil
          @totalhits = 0
        else
          @totalhits = totalhits(hits[0][0].gsub(",","").to_i)
        end
      end
      
      def crawl_people(html)
        html.scan(/<a href="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)" class=l[\sonmousedown="return clk(this.href,'','','res','\d','')"]*>([\w\s]*) \|/).each do |profile|
          name,last = profile[1].split(" ") 
          @people << [name,last] 
          @results << [[name,last], "P", self.class.to_s.upcase, "N"]
        end
      end
    end
  end
end
