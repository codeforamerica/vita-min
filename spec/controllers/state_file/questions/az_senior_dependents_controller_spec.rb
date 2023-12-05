require 'rails_helper'

RSpec.describe StateFile::Questions::AzSeniorDependentsController do
  describe ".show?" do
    context "with any senior dependents" do
      it "returns true" do
        intake = create(:state_file_az_intake, dependents: [create(:az_senior_dependent)])
        sign_in intake
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "without senior dependents" do
      it "returns false" do
        intake = create(:state_file_az_intake, dependents: [create(:state_file_dependent)])
        sign_in intake
        expect(described_class.show?(intake)).to eq false
      end
    end
  end
end
