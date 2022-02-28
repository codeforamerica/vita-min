module SubmissionBuilder
  class Base
    include SubmissionBuilder::FormattingMethods
    attr_accessor :submission, :schema_file, :schema_version
    class << self
      attr_reader :root_node
    end


    def initialize(submission, validate: true, documents: [])
      @submission = submission
      @validate = validate
      @documents = documents
      @schema_version = determine_default_schema_version_by_tax_year
    end

    def root_node_attrs
      { "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" }
    end

    def document
      raise "SubmissionBuilder classes must implement their own document method that returns a Nokogiri::XML::Document object"
    end

    def determine_default_schema_version_by_tax_year
      case @submission.tax_return.year
      when 2021
        "2021v5.2"
      when 2020
        "2020v5.1"
      end
    end

    def schema_file
      raise "Child classes of SubmissionBuilder::Base must define a schema_file method."
    end

    def build
      errors = []
      if @validate
        xsd = Nokogiri::XML::Schema(File.open(schema_file))
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
