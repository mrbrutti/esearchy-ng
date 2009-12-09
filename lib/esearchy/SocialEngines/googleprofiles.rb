module ESearchy  
  module SocialEngines
    class GoogleProfiles < ESearchy::GenericEngine
      ENGINE = "www.google.com"
      PORT  = 80
      NUM = 100
      TYPE = 2
      
      def search 
        @querypath = "/cse?q=site:www.google.com+intitle:%22Google+" +
                     "Profile%22+%22Companies+I%27ve+worked+for%22+%22at+" +  
                     CGI.escape(@company) + "%22&hl=en&cof=&num=100&filter=0&safe=off&start=" or
                     raise ESearchyMissingCompany, "Mssing website url Object.company=(value)"
        super
      end
            
      def parse( html )
        #Results <b>1</b> - <b>8</b> of <b>8</b> from <b>www.google.com</b>
        hits = html.scan(/<\/b> of <b>(.*)<\/b> from /)
        if hits.empty? or hits == nil
          @totalhits = 0
        else
          @totalhits = totalhits(hits[0][0].gsub(",","").to_i) unless @was_here
        end
      end
      
      def crawl_people(text)
        text.scan(/<a href="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)" class=l[\sonmousedown="return clk(this.href,'','','res','\d','')"]*>([\w\s]*) -/).each do |profile|
          name,last = profile[1].split(" ") 
          @people << [name,last]
          @results << [[name,last], "P", self.class.to_s.upcase, "N"]
        end
      end
    end
  end
end
