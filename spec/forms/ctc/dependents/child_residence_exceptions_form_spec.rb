require 'rails_helper'

describe Ctc::Dependents::ChildResidenceExceptionsForm do
  describe "#save" do
    let(:intake) { create :ctc_intake }
    let(:dependent) { create :dependent, intake: intake, months_in_home: 6 }

    it "saves fields on the dependent" do
      expect {
        form = described_class.new(dependent, {
          permanent_residence_with_client: "no"
        })
        form.save
      }.to change(dependent, :permanent_residence_with_client).to("no")
    end
  end
end