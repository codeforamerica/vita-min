require 'rails_helper'

describe Ctc::Dependents::ChildCanBeClaimedByOtherForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }

    it "saves the field on the dependent" do
      expect {
        form = described_class.new(dependent, { can_be_claimed_by_other: "yes" })
        form.save
      }.to change(dependent, :can_be_claimed_by_other).to("yes")
    end
  end
end