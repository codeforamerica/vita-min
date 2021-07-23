require 'rails_helper'

describe Ctc::Dependents::ChildLivedWithYouForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }

    it "saves the field on the dependent" do
      expect {
        form = described_class.new(dependent, { lived_with_more_than_six_months: "yes" })
        form.save
      }.to change(dependent, :lived_with_more_than_six_months).to("yes")
    end
  end
end