module Buildable
  extend ActiveSupport::Concern

  def build
    errors = []
    if @validate
      xsd = Nokogiri::XML::Schema(File.open(schema_file))
      xml = Nokogiri::XML(document.to_xml)
      errors = xsd.validate(xml)
    end
    SubmissionBuilder::Response.new(errors: errors, document: document, root_node: root_node)
  end

  class_methods do
    def build(*args)
      new(*args).build
    end
  end
end