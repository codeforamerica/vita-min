require "rails_helper"

RSpec.describe Documents::CareProviderStatementsController, type: :controller do
  let(:attributes) { {} }
  let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

  describe ".show?" do
    context "when they paid dependent care" do
      let(:attributes) { { paid_dependent_care: "yes" } }

      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "for other cases" do
      let(:attributes) do
        { paid_dependent_care: "no" }
      end

      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end
end
