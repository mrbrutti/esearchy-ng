module ESearchy  
  module SocialEngines
    class Plaxo < ESearchy::GenericEngine
      ENGINE = "www.google.com"
      PORT  = 80
      NUM = 100
      TYPE = 2
      
      def search
        @querypath = "/cse?q=site:plaxo.com/profile/show/+Work+*+" +
                     "#{CGI.escape(@company)}\"" +  
                     "&hl=en&cof=&num=100&filter=0&safe=off&start=" or
                     raise ESearchyMissingCompany, "Mssing website url Object.company=(value)"
        super
      end
            
      def parse( html )
        #Results <b>1</b> - <b>8</b> of <b>8</b> from <b>www.google.com</b>
        hits = html.scan(/<\/b> of [\w\s]*<b>(.*)<\/b> from /)
        if hits.empty? or hits == nil
          @totalhits = 0
        else
          @totalhits = totalhits(hits[0][0].gsub(",","").to_i)
        end
      end
      
      def crawl_people(text)
        text.scan(/<a href="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)" class=l[\sonmousedown="return clk(this.href,'','','res','\d','')"]*>([\w\s]*)&#39;/).each do |profile|
          pf = profile[0].to_s
          pf = pf.scan(/\/url\?q=([0-9A-Za-z:\\\/?=@+%.;"'()_-]+)&amp/).to_s if pf.match(/\/url\?q=/)
          p = profile[1].split(" ")
          @people << [ p, pf ]
          @results << [p, "P", pf, self.class.to_s.upcase, "N"]
        end
      end
    end
  end
end