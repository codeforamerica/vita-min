require 'rails_helper'

describe Ctc::Dependents::QualifyingRelativeForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }

    it "saves the field on the dependent" do
      expect {
        form = described_class.new(dependent, { meets_misc_qualifying_relative_requirements: "yes" })
        form.save
      }.to change(dependent, :meets_misc_qualifying_relative_requirements).to("yes")
    end
  end
end