require 'rails_helper'

describe Ctc::Dependents::RelativeFinancialSupportForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }

    it "saves the field on the dependent" do
      expect {
        form = described_class.new(dependent, { filer_provided_over_half_support: "yes" })
        form.save
      }.to change(dependent, :filer_provided_over_half_support).to("yes")
    end
  end
end