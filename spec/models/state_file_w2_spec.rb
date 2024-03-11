# == Schema Information
#
# Table name: state_file_w2s
#
#  id                       :bigint           not null, primary key
#  employer_state_id_num    :string
#  local_income_tax_amt     :integer
#  local_wages_and_tips_amt :integer
#  locality_nm              :string
#  state_file_intake_type   :string
#  state_income_tax_amt     :integer
#  state_wages_amt          :integer
#  w2_index                 :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  state_file_intake_id     :bigint
#
# Indexes
#
#  index_state_file_w2s_on_state_file_intake  (state_file_intake_type,state_file_intake_id)
#

require "rails_helper"

describe StateFileW2 do

  context "validation" do
    let(:intake) { create :state_file_ny_intake }
    let(:w2) {
      create(:state_file_w2,
        employer_state_id_num: "001245788",
        local_income_tax_amt: 200,
        local_wages_and_tips_amt: 8000,
        locality_nm: "NYC",
        state_file_intake: intake,
        state_income_tax_amt: 600,
        state_wages_amt: 8000,
        w2_index: 0,
      )
    }

    it "validates" do
      expect(w2).to be_valid
    end

    [:w2_index, :state_wages_amt, :state_income_tax_amt, :local_wages_and_tips_amt, :local_income_tax_amt].each do |field|
      context field do

        it "does not permit strings" do
          w2.send("#{field}=", "nope")
          expect(w2).not_to be_valid
          expect(w2.errors[field]).to be_present
        end

        it "does not permit floats" do
          w2.send("#{field}=", 3.14159)
          expect(w2).not_to be_valid
          expect(w2.errors[field]).to be_present
        end

        it "does not permit values less than 0" do
          w2.send("#{field}=", -1)
          expect(w2).not_to be_valid
          expect(w2.errors[field]).to be_present
        end
      end
    end

    it "requires both locality_nm to be present if wages_and_tips_amt is present" do
      w2.locality_nm = nil
      expect(w2).not_to be_valid
      expect(w2.errors[:locality_nm]).to be_present
    end

    it "permits both locality_nm and local_wages_and_tips_amt to be missing" do
      w2.locality_nm = nil
      w2.local_wages_and_tips_amt = 0
      w2.local_income_tax_amt = 0
      expect(w2).to be_valid
    end

    it "requires local_income_tax_amt to be less than local_wages_and_tips_amt" do
      w2.local_wages_and_tips_amt = 0
      expect(w2).not_to be_valid
      expect(w2.errors[:local_income_tax_amt]).to be_present
    end

    it "requires state_income_tax_amt to be less than state_wages_amt" do
      w2.state_wages_amt = 0
      expect(w2).not_to be_valid
      expect(w2.errors[:state_income_tax_amt]).to be_present
    end

    it "permits state_wages_amt to be blank if state_income_tax_amt is blank" do
      w2.state_wages_amt = 0
      w2.state_income_tax_amt = 0
      expect(w2).to be_valid
    end

    it "requires employer_state_id_num to be present if state_income_tax_amt is present" do
      w2.employer_state_id_num = nil
      expect(w2).not_to be_valid
      expect(w2.errors[:employer_state_id_num]).to be_present
    end

    it "permits state_wages_amt to be blank if state_income_tax_amt is blank" do
      w2.employer_state_id_num = nil
      w2.state_wages_amt = 0
      w2.state_income_tax_amt = 0
      expect(w2).to be_valid
    end

    it "rejects localities without the correct prefix" do
      w2.locality_nm = "YONKERS"
      expect(w2).not_to be_valid
      expect(w2.errors[:locality_nm]).to be_present
    end

    it "permits localities prefixed with an approved value" do
      w2.locality_nm = "NYC JK ITS YONKERS"
      expect(w2).to be_valid
    end

  end
end
