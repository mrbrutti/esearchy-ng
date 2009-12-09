require 'spidr'
require 'json'

module ESearchy  
  module OtherEngines
    class Spider < ESearchy::GenericEngine
      ENGINE = "" #Do not really need any of them. 
      PORT  = 0
      NUM = 0
      TYPE = 1 
      
      def search 
        Spidr.site(website()) do |spider|
          spider.every_page do |page|
            D page.url
            crawler(page.body)
            parse(page.body)
          end
        end
      end
      
      def website
        begin
          ESearchy::Search.website || @website
        rescue
          raise ESearchyMissingWebsite, "Mssing website url Object.website=(value)"
        end
      end
      
      def website=(v)
        @website=v
      end
            
      def parse( html )
        array = html.scan(/href=["|']([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)["|']/).map! do |r|
          r[0].match(/http:\/\/|https:\/\/|ftp:\/\//) ? r : [website() + r[0]]
        end
        super array
      end
      
    end
  end
end
