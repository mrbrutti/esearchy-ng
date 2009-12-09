require 'base64'

module ESearchy
  class Bugmenot  
    def self.fetch(domain = "www.linkedin.com")
      begin
        url = Net::HTTP.get URI.parse("http://www.bugmenot.com/view/#{domain}")
        key = ( url.scan(/var key =(.*);/)[0][0].to_i + 112 ) / 12
    
        user, pass = url.scan(/tr><th>Username <\/th><td><script>d\('(.*)'\);<\/script><\/td><\/tr>
  [\n\s]+<tr><th>Password <\/th><td><script>d\('(.*)'\);<\/script><\/td><\/tr>/)[0]
        user = decode(user,key)
        pass = decode(pass,key)
        return [user, pass]
      rescue
        return [nil,nil]
      end
    end
    
    private
    def decode(input, offset)
      # thanks tlrobinson @ github
      input.unpack("m*")[0][4..-1].unpack("C*").map{|c| c - offset }.pack("C*")
    end
  end
end