require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Nj::Documents::NjW2, required_schema: "nj" do
  describe ".document" do
    let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }
    let(:primary_ssn_from_fixture) { intake.primary.ssn }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:df_w2) { submission.data_source.direct_file_data.w2s[0] }
    let(:build_response) { described_class.build(submission, validate: true, kwargs: { w2: df_w2, intake_w2: test_w2 }) }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    context "with box 14 values" do
      let!(:test_w2) { 
        create(
        :state_file_w2,
        state_file_intake: intake,
        employee_ssn: primary_ssn_from_fixture,
        box14_ui_hc_wd: 99,
        box14_fli: 100, 
        employer_ein: '123456789', 
        wages: '999'
        )
      }

      it "adds box 14 nodes" do
        box_14_nodes = xml.css("OtherDeductsBenefits")

        expect(box_14_nodes[0].at('Desc').text).to eq('414HSUB')
        expect(box_14_nodes[0].at('Amt').text).to eq('250')

        expect(box_14_nodes[1].at('Desc').text).to eq('UI/HC/WD')
        expect(box_14_nodes[1].at('Amt').text).to eq('99')

        expect(box_14_nodes[2].at('Desc').text).to eq('FLI')
        expect(box_14_nodes[2].at('Amt').text).to eq('100')
      end
    end
  end
end