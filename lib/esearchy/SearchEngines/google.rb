module ESearchy  
  module SearchEngines
    class Google < ESearchy::GenericEngine
      ENGINE = "www.google.com"
      PORT  = 80
      NUM = 100
      TYPE = 1
      
      def search 
        @querypath = "/cse?&safe=off&num=100&site=&q=" +  @query  + "&btnG=Search&start="
        super
      end
            
      def parse( html )
        hits = html.scan(/<\/b> of [\w\s]*<b>(.*)<\/b> for /)
        if hits.empty? or hits == nil
          @totalhits = 0
        else
          @totalhits = totalhits(hits[0][0].gsub(",","").to_i)
        end
        super html.scan(/<div class=g><span class="b w xsm">\[([A-Z]+)\]<\/span> \
<h2 class=r><a href="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)"|<h2 class=r><a href="\
([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)"/)
      end
    end
  end
end

  
  