require 'rails_helper'

spec_vars = {
  default: {
    w2_node_name: "IRSW2",
    employer_state_id_num_name: "EmployerStateIdNum",
    locality_name: "LocalityNm"
  },
  nj: {
    w2_node_name: "NJW2",
    employer_state_id_num_name: "EmployersStateIdNumber",
    locality_name: "NameOfLocality"
  }
}

describe SubmissionBuilder::StateReturn do
  states_requiring_w2s = StateFile::StateInformationService.active_state_codes.excluding("nc", "id")
  # TODO? refactor so it just looks at w2 count; move w2 testing for NJ into own file
  states_requiring_w2s.each do |state_code|
    describe "#w2s", required_schema: state_code do
      let(:builder_class) { StateFile::StateInformationService.submission_builder_class(state_code) }
      let(:intake) { create("state_file_#{state_code}_intake".to_sym, filing_status: filing_status) }
      let(:submission) { create(:efile_submission, data_source: intake) }
      let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
      let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
      let(:vars) { spec_vars[state_code.to_sym] || spec_vars[:default] }

      context "#{state_code}: when there are w2s present" do
        let(:filing_status) { 'single' }
        let!(:state_file_w2) {
          create(
            :state_file_w2,
            state_file_intake: intake,
            w2_index: 1,
            employer_state_id_num: "00123",
            local_income_tax_amount: "0",
            local_wages_and_tips_amount: "2000",
            locality_nm: "Localitea",
            state_income_tax_amount: "700",
            state_wages_amount: "2000",
          )
        }

        it "copies over values from the state_file_w2s" do
          xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)

          w2_from_db = xml.css(vars[:w2_node_name])[0]
          expect(w2_from_db.at(vars[:employer_state_id_num_name]).text).to eq state_file_w2.employer_state_id_num
          expect(w2_from_db.at("LocalIncomeTaxAmt")).to be_nil
          expect(w2_from_db.at("LocalWagesAndTipsAmt").text).to eq state_file_w2.local_wages_and_tips_amount.round.to_s
          expect(w2_from_db.at(vars[:locality_name]).text).to eq state_file_w2.locality_nm
          expect(w2_from_db.at("StateIncomeTaxAmt").text).to eq state_file_w2.state_income_tax_amount.round.to_s
          expect(w2_from_db.at("StateWagesAmt").text).to eq state_file_w2.state_wages_amount.round.to_s
        end
      end
    end
  end

  states_requiring_1099gs = StateFile::StateInformationService.active_state_codes.excluding("nj")
  states_requiring_1099gs.each do |state_code|
    describe "#form1099gs", required_schema: state_code do
      context "#{state_code}: when there are 1099gs present" do
        let(:builder_class) { StateFile::StateInformationService.submission_builder_class(state_code) }
        let(:intake) { create("state_file_#{state_code}_intake".to_sym) }
        let(:submission) { create(:efile_submission, data_source: intake) }
        let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
        let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
        let!(:form1099g_1) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 100) }
        let!(:form1099g_2) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 200) }

        it "builds all 1099gs from intake" do
          xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)

          expect(xml.css("State1099G").count).to eq 2
        end
      end
    end
  end
end
