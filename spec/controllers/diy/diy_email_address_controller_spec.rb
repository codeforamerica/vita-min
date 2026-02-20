require "rails_helper"

RSpec.describe Diy::DiyEmailAddressController do
  render_views

  test_email_address = 'test@test.test'

  let(:diy_intake) { create(:diy_intake, email_address: test_email_address, email_notification_opt_in: "yes") }

  before do
    allow(subject).to receive(:current_diy_intake).and_return(diy_intake)
    allow(MixpanelService).to receive(:send_event)
  end

  describe ".show?" do
    context "when they do not have an email address and opted in to email" do
      let!(:diy_intake) { create :diy_intake, email_notification_opt_in: "yes" }
      xit "returns true" do
        pry
        expect(described_class.show?(diy_intake)).to eq true
      end
    end

    context "when they have an email" do
      let!(:diy_intake) { create :diy_intake, email_notification_opt_in: "yes", email_address: "email@example.test" }
      xit "returns false" do
        expect(described_class.show?(diy_intake)).to eq false
      end
    end

    context "when they have not opted in to email" do
      let!(:diy_intake) { create :diy_intake, email_notification_opt_in: "no" }
      xit "returns false" do
        expect(described_class.show?(diy_intake)).to eq false
      end
    end
  end

  describe "#edit" do
    it "renders successfully" do
      get :edit, session: { diy_intake_id: diy_intake.id }
      expect(response).to be_successful
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          diy_email_address_form: {
            email_address: "iloveplant@example.test",
            email_address_confirmation: "iloveplant@example.test",
          }
        }
      end

      it "sets the email address on the diy_intake" do
        expect do
          post :update, params: params, session: { diy_intake_id: diy_intake.id }
        end.to change { diy_intake.reload.email_address }
          .from(test_email_address)
          .to("iloveplant@example.test")
      end

      it "sends an event to mixpanel without the email address data" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "question_answered",
          data: {}
        ))
      end
    end

    context "with non-matching email addresses" do
      let(:params) do
        {
          diy_email_address_form: {
            email_address: "iloveplant@example.test",
            email_address_confirmation: "iloveplarnt@example.test",
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(response.body).to include("Please double check that the email addresses match.")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "validation_error",
          data: {
            invalid_email_address_confirmation: true
          })
        )
      end
    end

    context "with an invalid email address" do
      let(:params) do
        {
          diy_email_address_form: {
            email_address: "iloveplant@example.",
            email_address_confirmation: "iloveplant@example.",
          }
        }
      end

      it "shows validation errors" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(response.body).to include("Please enter a valid email address.")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(MixpanelService).to have_received(:send_event).with(hash_including(
          event_name: "validation_error",
          data: {
            invalid_email_address: true
          }
        ))
      end
    end
  end
end
