module SubmissionBuilder
  class Base
    include SubmissionBuilder::FormattingMethods
    attr_accessor :submission
    class << self
      attr_reader :schema_file, :root_node
    end

    @schema_file = nil # class instance variable

    def initialize(submission, validate: true, documents: [])
      @submission = submission
      @validate = validate
      @documents = documents
    end

    def root_node_attrs
      { "xmlns:efil" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" }
    end

    def document
      raise "SubmissionBuilder classes must implement their own document method that returns a Nokogiri::XML::Document object"
    end

    def build
      errors = []
      if @validate
        xsd = Nokogiri::XML::Schema(File.open(self.class.schema_file))
        xml = Nokogiri::XML(document.to_xml)
        errors = xsd.validate(xml)
      end
      SubmissionBuilder::Response.new(errors: errors, document: document, root_node: self.class.root_node)
    end

    def self.build(*args)
      new(*args).build
    end
  end
end
