require 'rails_helper'

describe Efile::Nj::NjStateWages do
  describe ".calculate_state_wages" do
    context "when no federal w2s" do
      let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }
      it "returns 0 to indicate the sum does not exist" do
        result = Efile::Nj::NjStateWages.calculate_state_wages(intake)
        expect(result).to eq(0)
      end
    end

    context "when many federal w2s" do
      let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }
      it "returns sum of state wages" do
        expected_sum = 50000 + 50000 + 50000 + 50000
        result = Efile::Nj::NjStateWages.calculate_state_wages(intake)
        expect(result).to eq(expected_sum)
      end
    end
  end
end
