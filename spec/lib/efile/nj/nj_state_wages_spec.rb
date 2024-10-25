require 'rails_helper'

describe Efile::Nj::NjStateWages do
  describe ".calculate_state_wages" do
    context "when no federal w2s" do
      it "returns -1" do
        # TODO
      end
    end

    context "when one federal w2" do
      it "returns sum of state wages" do
        # TODO
      end
    end

    context "when 2 federal w2s" do
      it "returns sum of state wages" do
        # TODO
      end
    end

    context "when many federal w2s" do
      it "returns sum of state wages" do
        # TODO
      end
    end
  end
end


# describe 'line 15 - state wages' do
#   context 'when no federal w2s' do
#     let(:intake) { create(:state_file_nj_intake, :df_data_minimal) }

#     it 'sets line 15 to -1 to indicate the sum does not exist' do
#       expect(instance.lines[:NJ1040_LINE_15].value).to eq(-1) # TODO: do we want -1 here?
#     end
#   end

#   context 'when 2 federal w2s' do
#     let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s) }

#     it 'sets line 15 to the sum of all state wage amounts' do
#       expected_sum = 12345 + 50000
#       expect(instance.lines[:NJ1040_LINE_15].value).to eq(expected_sum)
#     end
#   end

#   context 'when many federal w2s' do
#     let(:intake) { create(:state_file_nj_intake, :df_data_many_w2s) }

#     it 'sets line 15 to the sum of all state wage amounts' do
#       expected_sum = 50000 + 50000 + 50000 + 50000
#       expect(instance.lines[:NJ1040_LINE_15].value).to eq(expected_sum)
#     end
#   end
# end

# describe 'line 27 - total income' do
#   let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s) }
#   it 'sets line 27 to the sum of all state wage amounts' do
#     line_15_w2_wages = 12345 + 50000
#     expect(instance.lines[:NJ1040_LINE_15].value).to eq(line_15_w2_wages)
#     expect(instance.lines[:NJ1040_LINE_27].value).to eq(line_15_w2_wages)
#   end
# end


# describe 'line 29 - gross income' do
#   let(:intake) { create(:state_file_nj_intake, :df_data_2_w2s) }
#   it 'sets line 29 to the sum of all state wage amounts' do
#     line_15_w2_wages = 12345 + 50000
#     expect(instance.lines[:NJ1040_LINE_15].value).to eq(line_15_w2_wages)
#     expect(instance.lines[:NJ1040_LINE_29].value).to eq(line_15_w2_wages)
#   end
# end
