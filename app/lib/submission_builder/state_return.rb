module SubmissionBuilder
  class StateReturn < SubmissionBuilder::Document
    def document
      @document = if state_schema_version.present?
                    build_xml_doc(build_xml_doc_tag, stateSchemaVersion: state_schema_version)
                  else
                    build_xml_doc(build_xml_doc_tag)
                  end
      build_headers
      build_main_document
      build_documents
      build_state_specific_tags(@document)
      @document
    end
    
    def pdf_documents
      included_documents.select { |item| item.pdf }
    end

    def build_headers
      @document.at("ReturnState").add_child(authentication_header)
      @document.at("ReturnState").add_child(return_header)
    end

    def build_main_document
      @document.at("ReturnState").add_child("<ReturnDataState></ReturnDataState>")
    end

    def build_documents
      if documents_wrapper
        @document.at("ReturnDataState").add_child(documents_wrapper)
      end
      attached_documents.each do |attached|
        @document.at(attached_documents_parent_tag).add_child(document_fragment(attached))
      end
    end

    def document_fragment(document)
      document[:xml_class].build(@submission, validate: false, kwargs: document[:kwargs]).document.at("*")
    end

    def authentication_header
      SubmissionBuilder::AuthenticationHeader.build(@submission, validate: false).document.at("*")
    end

    def return_header
      SubmissionBuilder::ReturnHeader.build(@submission, validate: false).document.at("*")
    end

    def attached_documents
      @attached_documents ||= xml_documents.map { |doc| { xml_class: doc.xml, kwargs: doc.kwargs } }
    end

    def xml_documents
      included_documents.select { |item| item.xml }
    end

    def included_documents
      supported_documents.map { |item| OpenStruct.new(**item, kwargs: item[:kwargs] || {}) if item[:include] }.compact
    end

    def w2_class
      SubmissionBuilder::ReturnW2
    end

    def combined_w2s
      @submission.data_source.direct_file_data.w2s.map.with_index do |w2, i|
        intake = @submission.data_source
        intake_w2 = intake.state_file_w2s.find { |w2| w2.w2_index == i } if intake.state_file_w2s.present?

        {
          xml: w2_class,
          pdf: w2_pdf,
          include: true,
          kwargs: { w2: w2, intake_w2: intake_w2 }
        }
      end
    end

    def form1099gs
      @submission.data_source.state_file1099_gs.map do |form1099g|
        {
          xml: form1099g_builder,
          pdf: nil,
          include: true,
          kwargs: { form1099g: form1099g }
        }
      end
    end

    def form1099g_builder
      SubmissionBuilder::State1099G
    end

    def form1099rs
      @submission.data_source.state_file1099_rs.map do |form1099r|
        {
          xml: form1099r_builder,
          pdf: nil,
          include: true,
          kwargs: { form1099r: form1099r }
        }
      end
    end

    def form1099r_builder
      SubmissionBuilder::State1099R
    end

    def form1099ints
      @submission.data_source.direct_file_json_data.interest_reports.each_with_index.map do |form1099int, index|
        {
          xml: form1099int_builder,
          pdf: nil,
          include: true,
          kwargs: { form1099int: form1099int, index: index, intake: @submission.data_source}
        }
      end
    end

    def form1099int_builder
      SubmissionBuilder::State1099Int
    end

    # default to nil
    def w2_pdf; end

    def state_schema_version; end

    def build_state_specific_tags(_); end

    def documents_wrapper; end
      
    def self.preparer_person_name; end
      
    def self.ptin; end
  end
end