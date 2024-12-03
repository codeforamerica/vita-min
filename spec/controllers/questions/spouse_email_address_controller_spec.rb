require "rails_helper"

RSpec.describe Questions::SpouseEmailAddressController do
  render_views

  let(:filing_joint) { "yes" }
  let(:intake) { create :intake, filing_joint: filing_joint }

  before do
    sign_in intake.client
    allow(MixpanelService).to receive(:send_event)
  end

  describe ".show?" do
    context "when they are filing jointly" do
      let(:filing_joint) { "yes" }
      it "returns true" do
        expect(subject.class.show?(intake)).to eq true
      end
    end

    context "when they are not filing jointly" do
      let(:filing_joint) { "no" }
      it "returns false" do
        expect(subject.class.show?(intake)).to eq false
      end
    end
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit
      expect(response).to be_successful
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          spouse_email_address_form: {
            spouse_email_address: "iloveplant@example.com",
            spouse_email_address_confirmation: "iloveplant@example.com",
          }
        }
      end

      it "sets the email address on the intake" do
        expect do
          post :update, params: params
        end.to change { intake.reload.spouse_email_address }
          .from(nil)
          .to("iloveplant@example.com")
      end

      it "sends an event to mixpanel without the email address data" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "question_answered",
          data: {}
        ))
      end
    end

    context "with non-matching email addresses" do
      let(:params) do
        {
          spouse_email_address_form: {
            spouse_email_address: "iloveplant@example.com",
            spouse_email_address_confirmation: "iloveplarnt@example.com",
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params

        expect(response.body).to include("Please double check that the email addresses match.")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "validation_error",
          data: {
            invalid_spouse_email_address_confirmation: true
          }
        ))
      end
    end

    context "with an invalid email address" do
      let(:params) do
        {
          spouse_email_address_form: {
            spouse_email_address: "iloveplant@example.",
            spouse_email_address_confirmation: "iloveplant@example.",
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params

        expect(response.body).to include("Please enter a valid email address.")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "validation_error",
          data: {
            invalid_spouse_email_address: true
          }
        ))
      end
    end
  end
end
