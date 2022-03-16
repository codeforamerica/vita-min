require 'rails_helper'

describe Ctc::Dependents::RelativeMemberOfHouseholdForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }

    it "saves the field on the dependent" do
      expect {
        form = described_class.new(dependent, { residence_lived_with_all_year: "yes" })
        form.save
      }.to change(dependent, :residence_lived_with_all_year).to("yes")
    end
  end
end