def D m
  puts m if ESearchy::log
end

module ESearchy
  
  @@log = false
  #BUGMENOT = ESearchy::Bugmenot::fetch("linkedin.com")
  
  def self.log
    @@log
  end
  
  def self.log=(v)
    @@log=v
  end
  
  
  class ESearchyMissingAppID < StandardError; end
  class ESearchyMissingQuery < StandardError; end
  class ESearchyMissingWebsite < StandardError; end
  class ESearchyMissingCompany < StandardError; end
  
  class Search
    
    EMAIL_ENGINES = {
      :Google         => ESearchy::SearchEngines::Google, 
      :Bing           => ESearchy::SearchEngines::Bing, 
      :Yahoo          => ESearchy::SearchEngines::Yahoo, 
      :Altavista      => ESearchy::SearchEngines::Altavista,
      :PGP            => ESearchy::OtherEngines::PGP, 
      :Spider         => ESearchy::OtherEngines::Spider,
      :Usenet         => ESearchy::OtherEngines::Usenet,
      :GoogleGroups   => ESearchy::OtherEngines::GoogleGroups  
    }

    PEOPLE_ENGINES = {
      :LinkedIn       => ESearchy::SocialEngines::LinkedIn, 
      :GoogleProfiles => ESearchy::SocialEngines::GoogleProfiles, 
      :Naymz          => ESearchy::SocialEngines::Naymz,
      :Classmates     => ESearchy::SocialEngines::Classmates
      }
      
    def initialize(args, &block)    
      @@query = args[:query] || nil
      @@company = args[:company] || nil
      @@maxhits = args[:maxhits] || nil
      @@start_at = args[:start_at] || nil
      @@website = args[:website] || nil
      ESearchy.log = args[:log] if args[:log]
      $emails = []
      $people = []
      $results = []
      block.call(self) if block_given?
    end
    
    def self.query
      @@query
    end
    
    def self.company
      @@company
    end
    
    def self.website
      @@website
    end
    
    def self.maxhits
      @@maxhits
    end
    
    def maxhits
      @@maxhits
    end
    
    def start(&block)
      block.call(self)
    end
    
    def emails
      $emails
    end
    
    def people
      $people
    end
    
    def results
      $results
    end
    
    def Emails(*args, &block)
      Emails.new(*args, &block)
    end
    
    def People(*args, &block)
      People.new(*args, &block)
    end
    
    module MetaType
      def results
        $results
      end
      
      def docs(&block)
        @engines.each_key {|e| @documents.concat(@engines[e].documents) }
        res = ESearchy::Docs.new(@documents)
        res.search
        $emails.concat(res.emails)
        $results.concat(res.results)
        block.call(res) if block_given?
      end
      
      def method_missing(name, *args)
        @engines[name.to_sym]
      end
      
      def maxhits=(v)
        @engines.each_key {|e| @engines[e].maxhits=v}
      end

      def [](v)
        @engine[v]
      end
      
      private
      def save_results(e)
        $results.concat(@engines[e].results)
      end
    end
    
    class Emails
      include MetaType
      
      def initialize(*args, &block)
        @engines={}
        @documents = []
        args.each do |e|
          @engines[e] = ESearchy::Search::EMAIL_ENGINES[e].new(Search.query)
        end
        self.maxhits=Search.maxhits if Search.maxhits
        block.call(self) if block_given?
      end
      attr_reader :emails
      
      def search(&block)
        @engines.each_key do |e| 
          @engines[e].search
          save_emails(e)
          save_results(e)
          block.call(@engines[e]) if block_given?
        end
        nil
      end
      
      private
      def save_emails(e)
        $emails.concat(@engines[e].emails)
      end
    end
    
    class People
      include MetaType
      
      def initialize(*args, &block)
        @engines={}
        args.each do |e|
          @engines[e] = ESearchy::Search::PEOPLE_ENGINES[e].new(Search.company)
        end
        self.maxhits=Search.maxhits if Search.maxhits
        block.call(self) if block_given?
      end
      
      def people
        $people
      end
      
      def search(&block)
        @engines.each_key do |e| 
          @engines[e].search
          save_people(e)
          save_results(e)
          block.call(self) if block_given?
        end
        nil
      end
      
      private
      def save_people(e)
        $people.concat(@engines[e].people)
      end
    end
  end
end
