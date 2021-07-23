module SubmissionBuilder
  class Return1040 < SubmissionBuilder::Base
    @schema_file = File.join(Rails.root, "vendor", "irs", "unpacked", "2020v5.1", "IndividualIncomeTax", "Ind1040", "Return1040.xsd")
    @root_node = "Return"

    def root_node_attrs
      super.merge(returnVersion: "2020v5.1")
    end

    def adv_ctc_irs1040
      SubmissionBuilder::Documents::AdvCtcIrs1040.build(@submission, validate: false).as_fragment
    end

    def scenario5
      [
        SubmissionBuilder::Documents::Scenario5Irs1040.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs1040Schedule1.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs1040Schedule3.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs1040Schedule8812.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs1040ScheduleEic.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs2441.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs8862.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs8863.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs8867.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs8880.build(@submission, validate: false).as_fragment,
        SubmissionBuilder::Documents::Scenario5Irs1040W2Suntrust.build(@submission, validate: false).as_fragment,
      ]
    end

    def return_header
      SubmissionBuilder::ReturnHeader1040.build(@submission, validate: false).as_fragment
    end

    def document
      document = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml['efile'].Return(root_node_attrs)
      end.doc
      document.at("Return").add_child(return_header)
      document.at("Return").add_child("<ReturnData documentCnt='#{scenario5.length}'></ReturnData>")
      scenario5.each do |attached|
        document.at("ReturnData").add_child(attached)
      end
      document
    end
  end
end