require 'rails_helper'

describe Ctc::Dependents::ClaimChildAnywayForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }

    it "saves the field on the dependent" do
      expect {
        form = described_class.new(dependent, { claim_regardless: "yes" })
        form.save
      }.to change(dependent, :claim_regardless).to("yes")
    end
  end
end