module ESearchy  
  module SearchEngines
    class Altavista < ESearchy::GenericEngine
      ENGINE = "www.altavista.com"
      PORT  = 80
      NUM = 100
      TYPE = 1
      
      def search 
        @querypath = "/web/results?itag=ody&kgs=0&kls=0&nbq=50&q=" + @query + "&stq="
        super
      end
            
      def parse( html )
        hits = html.scan(/AltaVista found (.*) results<\/A>/) 
        if hits.empty? or hits == nil
          @totalhits = 0
        else
          @totalhits = totalhits(hits[0][0].gsub(',','').to_i)
        end
        super html.scan(/<a class='res' href='([a-zA-Z0-9:\/\/.&?%=\-_+]*)'>/)
      end
    end
  end
end