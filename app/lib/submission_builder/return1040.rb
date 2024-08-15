# This is specific to the 1040 because the 1040 Return Header is hard coded into the built logic.
module SubmissionBuilder
  class Return1040 < SubmissionBuilder::Document
    def attached_documents
      raise "Child classes must define a list of documents to include in XML ReturnData node"
    end

    def document
      document = build_xml_doc('efile:Return', returnVersion: @schema_version)
      document.at("Return").add_child(return_header)
      document.at("Return").add_child("<ReturnData documentCnt='#{attached_documents.length}'></ReturnData>")
      attached_documents.each do |attached|
        document.at("ReturnData").add_child(document_fragment(attached))
      end
      document
    end

    private

    def document_fragment(document)
      document[:xml_class].build(@submission, validate: false, kwargs: document[:kwargs]).document.at("*")
    end

    def return_header
      SubmissionBuilder::ReturnHeader1040.build(@submission, validate: false).document.at("*")
    end

    def schema_file
      SchemaFileLoader.load_file("irs", "unpacked", @schema_version, "IndividualIncomeTax", "Ind1040", "Return1040.xsd")
    end
  end
end
