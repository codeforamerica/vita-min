module SubmissionBuilder
  class Document
    include SubmissionBuilder::FormattingMethods
    attr_accessor :submission, :schema_file, :schema_version

    def initialize(submission, validate: true, kwargs: {})
      @submission = submission
      @validate = validate
      @schema_version = determine_default_schema_version_by_tax_year
      @kwargs = kwargs
    end

    def document
      raise "SubmissionBuilder classes must implement their own document method that returns a Nokogiri::XML::Document object"
    end

    def determine_default_schema_version_by_tax_year
      case @submission.tax_return&.year || @submission.data_source&.tax_return_year
      when 2023
        "2023v3.0"
      when 2022
        "2022v5.3"
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
      SubmissionBuilder::Response.new(errors: errors, document: document)
    end

    def self.build(*args)
      new(args[0], **(args[1] || {})).build
    end

    private

    def build_xml_doc(tag_name, **root_node_attributes)
      default_attributes = { "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" }
      xml_builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.send(tag_name, default_attributes.merge(root_node_attributes)) do |contents_builder|
          yield contents_builder if block_given?
        end
      end
      xml_builder.doc
    end
  end
end
