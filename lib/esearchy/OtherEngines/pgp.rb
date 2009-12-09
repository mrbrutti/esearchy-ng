module ESearchy
  module OtherEngines
    class PGP < ESearchy::GenericEngine
      ENGINE = "pgp.mit.edu"
      PORT  = 11371
      NUM = 0 # Do not really ned it :)
      TYPE = 1
      
      def search 
        @querypath = "/pks/lookup?search=" + @query
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