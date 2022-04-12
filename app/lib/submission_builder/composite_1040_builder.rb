# This is specific to the 1040 because the 1040 Return Header is hard coded into the built logic.
module SubmissionBuilder
  class Composite1040Builder < SubmissionBuilder::Base
    @root_node = "Return"

    def attached_documents
      raise "Child classes must implement a list of executable document classes"
    end

    def document
      document = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml['efile'].Return(root_node_attrs)
      end.doc
      document.at("Return").add_child(return_header)
      document.at("Return").add_child("<ReturnData documentCnt='#{attached_documents.length}'></ReturnData>")
      attached_documents.each do |attached|
        document.at("ReturnData").add_child(document_fragment(attached))
      end
      document
    end

    private

    def document_fragment(class_name)
      class_name.constantize.build(@submission, validate: false).as_fragment
    end

    def return_header
      SubmissionBuilder::ReturnHeader1040.build(@submission, validate: false).as_fragment
    end

    def schema_file
      File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "IndividualIncomeTax", "Ind1040", "Return1040.xsd")
    end

    def root_node_attrs
      super.merge(returnVersion: @schema_version)
    end
  end
end