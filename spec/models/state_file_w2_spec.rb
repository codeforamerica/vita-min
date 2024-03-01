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
        w2_index: 0
      )
    }

    it "validates" do
      binding.pry
      expect(w2).to be_valid
    end

  end
end
