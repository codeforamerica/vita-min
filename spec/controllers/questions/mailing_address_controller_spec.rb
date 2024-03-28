require "rails_helper"

RSpec.describe Questions::MailingAddressController do
  render_views

  let(:intake) { create :intake }

  before do
    sign_in intake.client
    allow(subject).to receive(:send_mixpanel_event)
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit
      expect(response).to be_successful
    end

    context "when the intake has mailing address" do
      before do
        intake.update(
          street_address: "789 Dogbert Court",
          city: "Canineville",
          state: "CA",
          zip_code: "91234"
        )
      end

      it "uses the mailing address from the intake" do
        get :edit
        expect(response.body).to include(intake.street_address)
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          mailing_address_form: {
            street_address: "30 Giraffe Terrace",
            city: "Oakland Heights",
            state: "CA",
            zip_code: "12345"
          }
        }
      end

      it "updates the mailing address of the intake" do
        expect do
          post :update, params: params
        end.to change { intake.reload.street_address }
          .from(nil)
          .to("30 Giraffe Terrace")
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          mailing_address_form: {
            street_address: "30 Giraffe Terrace",
            state: "CA",
            zip_code: "2233"
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params

        expect(response.body).to include("Can't be blank.")
        expect(response.body).to include("Please enter a valid 5-digit zip code.")
      end
    end
  end
end
