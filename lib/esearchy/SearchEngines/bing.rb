module ESearchy  
  module SearchEngines
    class Bing < ESearchy::GenericEngine
      ENGINE = "api.search.live.net"
      PORT  = 80
      NUM = 50
      TYPE = 1
      
      def search
        @querypath = "/json.aspx?AppId=" + @appid + "&query=" + @query +
                     "&Sources=Web&Web.Count=50&Web.Offset=" or 
                     raise ESearchyMissingAppID, "Missing AppID <Class.appid=>"
        super
      end
      
      def appid=(value)
        @appid = value
      end
      
      def parse(json)
        doc = JSON.parse(json)
        hits = doc["SearchResponse"]["Web"]["Total"].to_i 
        if hits == nil or hits == 0
          @totalhits = 0
        else
          @totalhits = totalhits(hits)
        end
        super doc["SearchResponse"]["Web"]["Results"]
      end
    end
  end
end