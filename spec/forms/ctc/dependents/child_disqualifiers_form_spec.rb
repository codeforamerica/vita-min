require 'rails_helper'

describe Ctc::Dependents::ChildDisqualifiersForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }
    let(:params) do
      {
        provided_over_half_own_support: "yes",
        filed_joint_return: "yes",
      }
    end

    it "saves the child disqualifier fields on the dependent" do
      expect {
        form = described_class.new(dependent, params)
        form.save
      }.to change(dependent, :provided_over_half_own_support).to("yes")
       .and change(dependent, :filed_joint_return).to("yes")
    end
  end
end