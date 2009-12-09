require 'net/https'
module ESearchy  
  module SocialEngines
    class LinkedIn < ESearchy::GenericEngine
      ENGINE = "www.linkedin.com"
      PORT  = 80
      NUM = 1
      TYPE = 2
      
      def search 
        @querypath = "/search?search=&currentCompany=co&company=" + CGI.escape(@company) +         
         "&proposalType=Y&newnessType=Y&pplSearchOrigin=MDYS&searchLocationType=Y&page_num=" or 
          raise ESearchyMissingCompany, "Mssing website url Object.company=(value)"
        super
      end
            
      def parse( html )
        p html
        p html.scan(/<p class="summary">[\n\s]+<strong>(.*)<\/strong> results/)#.gsub(/,|./,"")
        #unless @was_here
        #  @totalhits= totalhits html.scan(/<p class="summary">[\n\s]+<strong>(.*)<\/strong> results/)[0][0].to_i
        #end 
      end
            
      def credentials=(c)
        @user = c[0].to_s
        @pwd = c[1].to_s
        LinkedIn.const_set :HEADER, login
        self.start=(1)
      end
      
      def maxhits=(v)
        super v/10
      end
      
      private
      def crawl_people(html)
        list = html.scan(/title="View profile">[\n\s]+<span class="given-name">(.*)<\/span>\
[\n\s]+<span class="family-name">(.*)<\/span>/)
        @people.concat(list).uniq!
        list.each { |p| @results << [p, "P", self.class.to_s.upcase, "N"] }
      end
      
      def login
        begin
          get ENGINE, PORT, "/secure/login?trk=hb_signin", {'User-Agent' => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1.5) Gecko/20091102"} do |r|
            @l_headers = r.to_hash
            @l_headers.each {|k,v| @l_headers[k] = v.to_s}
            @csrfToken = r.body.scan(/<input type="hidden" name="csrfToken" value="ajax:(.*)">/)[0][0]
            puts "------------------------------------------------------------------------------------"
            puts "------------------------------------------------------------------------------------"
            p @l_headers
            p @csrfToken
            puts "------------------------------------------------------------------------------------"
            puts "------------------------------------------------------------------------------------"
          end
          http = Net::HTTP.new(ENGINE,443)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.start do |http|
            body = "csrfToken=ajax:#{@csrfToken}" +
                   "session_key=#{@user}" +
                   "&session_password=#{@pwd}" +
                   "&session_login=Sign+In&session_login=&session_rikey="
                   
                  @l_headers['Host'] = "www.linkedin.com"
                  @l_headers['User-Agent'] = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.6; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5"
                  @l_headers['Accept'] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
                  @l_headers['Accept-Language'] = "en-us,en;q=0.5"
                  @l_headers['Accept-Charset'] = "ISO-8859-1,utf-8;q=0.7,*;q=0.7"
                  @l_headers['Keep-Alive'] = "300"
                  @l_headers['Connection'] = "keep-alive"
                  @l_headers['Referer'] = "https://www.linkedin.com/secure/login?trk=hb_signin"
                  @l_headers['Cookie'] = "JSESSIONID=\"ajax:5367441617418183976\"; visit=G; bcookie=\"v=1&8231965c-b4b7-48f2-8349-76514ba89b69\"; lang=\"v=2&lang=en&c=\"; NSC_MC_QH_MFP=e242089229a3; __utma=226841088.2037160969.1259078198.1259078198.1259078198.1; __utmb=226841088.2.10.1259078198; __utmc=226841088; __utmz=226841088.1259078198.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utmv=226841088.user; leo_auth_token=\"GST:9_t6crYtB4AWStfoqhWQ6LYPKakWfHk_dotQyAHagiRX1HlEvqVt5-:1259081816:56d4aecb2e985d7f8a30d74e758f261ea8b92065\"; NSC_MC_WT_YUSL_IUUQ=e2420f8429a0"
                  @l_headers['Content-Type'] = "application/x-www-form-urlencoded"
                  @l_headers['Content-Length'] = body.size.to_s
             
            request = Net::HTTP::Post.new("/secure/login", @l_headers)
            request.body = CGI.escape(body)
            response = http.request(request)
            case response
            when Net::HTTPSuccess, Net::HTTPRedirection
              puts "------------------------------------------------------------------------------"
              puts "------------------------------------------------------------------------------"
              p response.to_hash
              p response.body
              puts "-----------------------------------------------------------------------------"
              puts "-----------------------------------------------------------------------------"
              return {'Cookie' => response['Set-Cookie'], 'User-Agent' => UserAgent::fetch} 
            else
              return response.error!
            end
          end
        rescue Net::HTTPFatalError
          D "Error: Something went wrong while login to LinkedIn.\n\t${$@}"
        end
      end
    end
  end
end