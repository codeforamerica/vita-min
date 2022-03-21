module SubmissionBuilder
  module TY2021
    class Return1040 < SubmissionBuilder::Base
      @root_node = "Return"

      def schema_file
        File.join(Rails.root, "vendor", "irs", "unpacked", @schema_version, "IndividualIncomeTax", "Ind1040", "Return1040.xsd")
      end

      def root_node_attrs
        super.merge(returnVersion: @schema_version)
      end

      def adv_ctc_irs1040
        SubmissionBuilder::TY2021::LapsedFilerIrs1040.build(@submission, validate: false).as_fragment
      end

      def return_header
        SubmissionBuilder::ReturnHeader1040.build(@submission, validate: false).as_fragment
      end

      def document
        document = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml['efile'].Return(root_node_attrs)
        end.doc
        document.at("Return").add_child(return_header)
        document.at("Return").add_child("<ReturnData documentCnt='#{@documents.length}'></ReturnData>")
        @documents.each do |attached|
          document.at("ReturnData").add_child(send(attached))
        end
        document
      end

      def build
        unless ENV['TEST_SCHEMA_VALIDITY_ONLY'] == 'true'
          raise NotImplementedError, "SubmissionBuilder::TY2021::Return1040 is for testing purposes only and does not currently conform to the 2021 revenue procedure."
        end

        super
      end
    end
  end
end