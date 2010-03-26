module ESearchy  
  class Profiling
    def initialize(people)
      @peo = people
      @people = []
      @results = []
    end
    attr_accessor :people, :results
    
    def search
      @peo.each { |person, profile| crawl(person, profile) }
    end
    
    private
    def get_profile(uri_str, limit = 10)
      # You should choose better exception.
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0
      response = Net::HTTP.get_response(URI.parse(uri_str))
      case response
      when Net::HTTPSuccess     then response.body
      when Net::HTTPRedirection then fetch(response['location'], limit - 1)
      else
        response.error!
      end
    end
    
    def crawl(person, profile)
      text = get_profile(profile)
      puts text
      case profile
      when /spoke.com/ then
        D "Crawling #{person}'s profile for co-workers:" 
        cw = text.scan(/<a class="personLinkTag" href="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)">([\w\s]*)<\/a>/)
        add_persons(cw, person, "http://www.spoke.com")
      when /classmate.com/ then
        return nil
      when /google.com/ then
        D "Crawling #{person}'s Google profile for other Social Networks"
        text.scan(/<div class="link"><a class="url" href="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)" rel="me">([\w\s]*)<\/a>/).each do |prof|
          url = prof[0]
          network = prof[1]
          D "\t-#{network} : #{url}"
        end
      when /jigsaw.com/ then
        D "Crawling #{person}'s JigSaw profile for co-workers:"
        cw = text.scan(/<li><p style="margin-top: 15px"><a href='([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)'>([\w\s]*)<\/a>/)
        add_persons(cw, person, "http://www.jigsaw.com")
      when /linkedin.com/ then
        return nil
      when /naymz.com/ then
        D "Crawling #{person}'s Google profile for other Social Networks"
        text.scan(/<a href="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)" rel="external">[\n\s]*([\w\s]*)\n/).each do |prof|
          url = prof[0]
          network = prof[1]
          D "\t-#{network} : #{url} "
        end
      when /plaxo.com/ then
        D "Crawling #{person}'s Plaxo profile for other Social Networks:"
        text.scan(/rel="me nofollow" title="([0-9A-Za-z:\\\/?&=@+%.;"'()_-]+)">([\w\s]*)<\/a><\/div><\/td>/).each do |prof|
          url = prof[0]
          network = url.scan(/:\/\/(.*)\./)[0][0]
          username = prof[1]
          D "\t-#{network} : #{username} : #{url} "
        end
      when /ziggs.com/ then
        return nil
      end 
    end
    
    def add_persons(cowork, per,  url)
      cowork.uniq.each do |profile|
        pf = url + profile[0].to_s
        p = profile[1].split(" ")
        D "\t-#{p} -> #{pf}"
        @people << [ p, pf ]
        @results << [p, "P", pf, per.to_s.upcase, "N"]
      end
    end
  end
end