require "rails_helper"

RSpec.describe Questions::OtherIncomeTypesController do
  let(:intake) { create :intake }

  before do
    sign_in intake.client
  end

  describe ".show?" do
    context "with an intake that reported no other income" do
      let!(:intake) { create :intake, had_other_income: "no" }

      it "returns false" do
        expect(Questions::OtherIncomeTypesController.show?(intake)).to eq false
      end
    end

    context "with an intake that has not filled out the other income column" do
      let!(:intake) { create :intake, had_other_income: "unfilled" }

      it "returns false" do
        expect(Questions::OtherIncomeTypesController.show?(intake)).to eq false
      end
    end

    context "with an intake that reported yes to other income" do
      let!(:intake) { create :intake, had_other_income: "yes" }

      it "returns true" do
        expect(Questions::OtherIncomeTypesController.show?(intake)).to eq true
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          other_income_types_form: {
            other_income_types: "Gnome sales",
          }
        }
      end

      before do
        allow(subject).to receive(:send_mixpanel_event)
      end

      it "does not send a mixpanel event" do
        post :update, params: params

        expect(subject).to have_received(:send_mixpanel_event).with(event_name: "question_answered", data: {})
      end
    end
  end
end

