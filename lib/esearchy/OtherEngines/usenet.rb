module ESearchy
  module OtherEngines
    class Usenet < ESearchy::GenericEngine
      ENGINE = "usenet-addresses.mit.edu"
      PORT  = 80
      NUM = 0 # Do not really ned it :)
      TYPE = 1
      
      def search
        @querypath = "/cgi-bin/udb?T=" + @query + "&G=&S=&N=&O=&M=500"
        get ENGINE, PORT, @querypath, {'User-Agent' => UserAgent::fetch } do |r|
          D "Searching #{self.class}"
          crawler(r.body)
        end
      end

      def parse( html )
        super html.scan(/href=["|']([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)["|']/)
      end
    end
  end
end