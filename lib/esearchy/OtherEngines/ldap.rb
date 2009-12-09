module ESearchy
  module OtherEngines
    class Ldap
      
      def initialize(host = nil, port = nil, base = nil, 
                     scope = nil, filter = nil, attr = nil)
        @HOST    = host
        @PORT    = port || LDAP::LDAP_PORT
        @base    = base || "dc=localhost,dc=#{host}"
        @scope   = scope || 2
        @filter  = filter || '(objectclass=person)'
        @attrs   = attr || ['sn', 'cn'] 
      end
      attr_accessor :HOST, :PORT, :SSLPORT, :base, :scope, :filter, :attrs
      
      def search(bind, &block)
        connect(bind)
        begin
          block.call(self) if block_given?
          @conn.search(base, scope, filter, attrs, block)
        rescue LDAP::ResultError
          @conn.perror("search")        
        end
        @conn.perror("search")
        close
      end  
      
      private
      
      def connect(bind)
        begin
          @conn = LDAP::Conn.new(@HOST, @PORT)
          @conn.bind(bind) # i.e. 'cn=root, dc=localhost, dc=localdomain','secret'
        rescue LDAP::Error
          @conn.perror("bind")
        end
      end
      
      def close
        @conn.unbind
      end
    end
  end
end
