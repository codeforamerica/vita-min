require 'rails_helper'

describe Efile::Nj::NjFlatEitcEligibility do
  describe ".possibly_eligible?" do
    [
      { traits: [], expected: false },
      { traits: [:df_data_minimal], expected: true },
    ].each do |test_case|
      context "when filing with #{test_case}" do
        let(:intake) do
          create(:state_file_nj_intake, *test_case[:traits])
        end

        it "returns #{test_case[:expected]}" do
          result = Efile::Nj::NjFlatEitcEligibility.possibly_eligible?(intake)
          expect(result).to eq(test_case[:expected])
        end
      end
    end
  end
end
