require "rails_helper"

RSpec.describe Diy::DiyNotificationPreferenceController do
  render_views

  example_email_addr = 'example@example.test' # http://www.faqs.org/rfcs/rfc2606.html

  let(:diy_intake) { create :diy_intake, email_address: example_email_addr }

  before do
    allow(subject).to receive(:current_diy_intake).and_return(diy_intake)
    allow(subject).to receive(:send_mixpanel_event)
  end

  describe "#edit" do
    let!(:diy_intake) { create :diy_intake, email_address: example_email_addr }

    it "renders successfully" do
      get :edit, session: { diy_intake_id: diy_intake.id }
      expect(response).to be_successful
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          diy_notification_preference_form: {
            email_notification_opt_in: "yes",
            sms_notification_opt_in: "no",
          }
        }
      end

      it "updates the diy_intake's notification preferences" do
        expect(diy_intake.sms_notification_opt_in).to eq("unfilled")
        expect(diy_intake.email_notification_opt_in).to eq("unfilled")

        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        diy_intake.reload
        expect(diy_intake.sms_notification_opt_in).to eq("no")
        expect(diy_intake.email_notification_opt_in).to eq("yes")
      end

      it "sends an event to mixpanel with relevant data" do
        post :update, params: params, session: { diy_intake_id: diy_intake.id }

        expect(subject).to have_received(:send_mixpanel_event).with(
          #event_name: "form_submission"
          event_name: "question_answered",
          data: {
            email_notification_opt_in: "yes",
            sms_notification_opt_in: "no",
          }
 
        )
      end
    end
  end
end
