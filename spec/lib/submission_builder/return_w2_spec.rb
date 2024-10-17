require 'rails_helper'

describe SubmissionBuilder::ReturnW2 do
  StateFile::StateInformationService.active_state_codes.excluding("ny").each do |state_code|
    describe ".document" do
      let(:submission) { create(:efile_submission, data_source: intake) }
      let(:intake) do
        create("state_file_#{state_code}_intake".to_sym)
      end
      let!(:state_file_w2) {
        create(
          :state_file_w2,
          state_file_intake: intake,
          w2_index: 1,
          employer_name: "Carton Network",
          employee_name: "Uovo",
          employer_state_id_num: "00123",
          local_income_tax_amount: "0",
          local_wages_and_tips_amount: "2000",
          locality_nm: "Localitea",
          state_income_tax_amount: "700",
          state_wages_amount: "2000",
        )
      }
      let(:doc) { described_class.new(submission, kwargs: { w2: state_file_w2 }).document }

      it "copies over values from the state_file_w2s" do
        expect(doc.at("EmployerName BusinessNameLine1Txt").text).to eq state_file_w2.employer_name
        expect(doc.at("EmployeeNm").text).to eq state_file_w2.employee_name
        expect(doc.at("EmployerStateIdNum").text).to eq state_file_w2.employer_state_id_num
        expect(doc.at("LocalIncomeTaxAmt")).to be_nil
        expect(doc.at("LocalWagesAndTipsAmt").text).to eq state_file_w2.local_wages_and_tips_amount.round.to_s
        expect(doc.at("LocalityNm").text).to eq state_file_w2.locality_nm
        expect(doc.at("StateIncomeTaxAmt").text).to eq state_file_w2.state_income_tax_amount.round.to_s
        expect(doc.at("StateWagesAmt").text).to eq state_file_w2.state_wages_amount.round.to_s
      end
    end
  end
end
