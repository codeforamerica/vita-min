require 'rails_helper'

describe Ctc::Dependents::ChildResidenceForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake }

    it "saves the field on the dependent" do
      expect {
        form = described_class.new(dependent, { months_in_home: 8 })
        form.save
      }.to change(dependent, :months_in_home).to(8)
    end
  end
end