require "rails_helper"

RSpec.describe Questions::MailingAddressController do
  render_views

  let(:user) do
    create(
      :user,
      street_address: "123 Cat Fancy Boulevard",
      city: "Meowtown",
      state: "CA",
      zip_code: "90210"
    )
  end
  let(:intake) { user.intake }

  before do
    allow(subject).to receive(:current_user).and_return(user)
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit
      expect(response).to be_successful
    end

    context "when mailing address on the intake is not present" do
      it "pre-fills mailing address from the user" do
        get :edit
        expect(response.body).to include(user.street_address)
      end
    end

    context "when the intake has mailing address" do
      before do
        intake.update_attributes(
          street_address: "789 Dogbert Court",
          city: "Canineville",
          state: "CA",
          zip_code: "91234"
        )
      end

      it "uses the mailing address from the intake" do
        get :edit
        expect(response.body).not_to include(user.street_address)
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
  end
end
