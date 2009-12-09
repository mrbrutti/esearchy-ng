module ESearchy
  module LocalEngines
    class Directory
      def initialize(dir)
        @documents = Queue.new
        @emails = []
      end
      
      def search
        files = Dir["#{@dir}/**/*.*"]
        files.select {|x| /.pdf$|.doc$|.docx$|.xlsx$|.pptx$|.odt$|.odp$|.ods$|.odb$|.txt$|.rtf$|.ans$|.csv$|.xml|.json$|.html$/i}.each { |f| @documents.push(f) }
      end
      
    end
  end
end