module ESearchy  
  module OtherEngines
    class GoogleGroups < ESearchy::GenericEngine
      ENGINE = "groups.google.com"
      PORT  = 80
      NUM = 100
      TYPE = 1
      
      def search 
        @querypath = "/groups/search?&safe=off&num=100&q=" +  @query  + "&btnG=Search&start="
        super
      end
            
      def parse( html )
        hits = html.scan(/<\/b> of about <b>(.*)<\/b> for /)
        if hits.empty? or hits == nil
          @totalhits = 0
        else
          @totalhits = totalhits(hits[0][0].gsub(",","").to_i)
        end
        super html.scan(/<div class=g align="left"><a href="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)" target=""/)
      end
    end
  end
end

  
