module ESearchy  
  module SearchEngines
    class Yahoo < ESearchy::GenericEngine
      ENGINE = "boss.yahooapis.com"
      PORT  = 80
      NUM = 50
      TYPE = 1
      
      def search
        @querypath = "/ysearch/web/v1/" + @query + 
                     "?appid="+ @appid + "&format=json&count=50" or 
                      raise ESearchyMissingAppID, "Missing AppID <Class.appid=>"
        super
      end
      
      def appid=(value)
        @appid = value
      end
      
      def parse(json)
        doc = JSON.parse(json) 
        hits = doc["ysearchresponse"]["totalhits"].to_i 
        if hits == nil or hits == 0
          @totalhits = 0
        else
          @totalhits = totalhits(hits)
        end
        super doc["ysearchresponse"]["resultset_web"]
      end
    end
  end
end
