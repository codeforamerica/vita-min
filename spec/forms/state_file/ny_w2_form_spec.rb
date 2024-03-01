require "rails_helper"

RSpec.describe StateFile::NyW2Form do
  let(:valid_params) do
    {
      w2s_attributes: {
        "0": {
          w2_index: 0,
          employer_state_id_num: "123",
          state_wages_amt: 100,
          state_income_tax_amt: 50,
          local_wages_and_tips_amt: 100,
          local_income_tax_amt: 50,
          locality_nm: "NYC",
        },
        "1": {
          w2_index: 1,
          employer_state_id_num: "234",
          state_wages_amt: 200,
          state_income_tax_amt: 100,
          local_wages_and_tips_amt: 200,
          local_income_tax_amt: 100,
          locality_nm: "NYC",
        }
      }
    }
  end
  let(:intake) { create :state_file_ny_intake, raw_direct_file_data: File.read(Rails.root.join("spec/fixtures/files/fed_return_batman_ny.xml")) }

  describe "#save" do
    context "with existing w2s" do
      before do
        intake.state_file_w2s.create!(w2_index: 0)
        intake.state_file_w2s.create!(w2_index: 1)
      end

      it "updates the existing w2s" do
        described_class.new(intake, valid_params).save

        first_w2 = intake.state_file_w2s.find_by(w2_index: 0).reload
        expect(first_w2.employer_state_id_num).to eq "123"
        expect(first_w2.state_wages_amt).to eq 100
        expect(first_w2.state_income_tax_amt).to eq 50
        expect(first_w2.local_wages_and_tips_amt).to eq 100
        expect(first_w2.local_income_tax_amt).to eq 50
        expect(first_w2.locality_nm).to eq "NYC"

        second_w2 = intake.state_file_w2s.find_by(w2_index: 1).reload
        expect(second_w2.employer_state_id_num).to eq "234"
        expect(second_w2.state_wages_amt).to eq 200
        expect(second_w2.state_income_tax_amt).to eq 100
        expect(second_w2.local_wages_and_tips_amt).to eq 200
        expect(second_w2.local_income_tax_amt).to eq 100
        expect(second_w2.locality_nm).to eq "NYC"
      end
    end

    context "with no existing w2s" do
      it "creates new w2s" do
        expect {
          described_class.new(intake, valid_params).save
        }.to change(StateFileW2, :count).by(2)

        first_w2 = intake.state_file_w2s.find_by(w2_index: 0).reload
        expect(first_w2.employer_state_id_num).to eq "123"
        expect(first_w2.state_wages_amt).to eq 100
        expect(first_w2.state_income_tax_amt).to eq 50
        expect(first_w2.local_wages_and_tips_amt).to eq 100
        expect(first_w2.local_income_tax_amt).to eq 50
        expect(first_w2.locality_nm).to eq "NYC"

        second_w2 = intake.state_file_w2s.find_by(w2_index: 1).reload
        expect(second_w2.employer_state_id_num).to eq "234"
        expect(second_w2.state_wages_amt).to eq 200
        expect(second_w2.state_income_tax_amt).to eq 100
        expect(second_w2.local_wages_and_tips_amt).to eq 200
        expect(second_w2.local_income_tax_amt).to eq 100
        expect(second_w2.locality_nm).to eq "NYC"
      end
    end
  end
end
