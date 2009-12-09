module ESearchy  
  module SocialEngines
    class Naymz < ESearchy::GenericEngine
      ENGINE = "www.google.com"
      PORT  = 80
      NUM = 100
      TYPE = 2
      
      def search 
        @querypath = "/cse?q=site:naymz.com%20%2B%20%22@%20" +  CGI.escape(@company)  +     
                     "%22&hl=en&cof=&num=100&filter=0&safe=off&start="
        super
      end
            
      def parse( html )
        #</b> of about <b>760</b> from <b>
        hits = html.scan(/<\/b> of about <b>(.*)<\/b> from/)
        if hits.empty? or hits == nil
           @totalhits = 0
         else
           @totalhits= totalhits hits[0][0].gsub(",","").to_i unless @was_here
         end
      end
      
      def crawl_people(html)
        html.scan(/<a href="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)" class=l[\sonmousedown="return clk(this.href,'','','res','\d','')"]*>([\w\s]*) -/).each do |profile|
          person = profile[1].split(" ").delete_if do 
            |x| x =~ /mr.|mr|ms.|ms|phd.|dr.|dr|phd|phd./i
          end
          @people << person
          @results << [person, "P", self.class.to_s.upcase, "N"]
        end
      end
    end
  end
end
