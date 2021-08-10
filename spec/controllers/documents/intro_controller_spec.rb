require "rails_helper"

RSpec.describe Documents::IntroController do
  render_views
  let(:attributes) { {} }
  let(:intake) { create :intake, visitor_id: "visitor_id", **attributes }
  before { sign_in intake.client }

  describe "#edit" do
    context "with a set of answers on an intake" do
      let(:attributes) { { had_wages: "yes", had_retirement_income: "yes" } }

      it "shows section headers for the expected document types" do
        get :edit

        expect(response.body).to include("Employment")
        expect(response.body).to include("1099-R")
        expect(response.body).not_to include("Other")
      end
    end

    context "mixpanel" do
      let(:fake_tracker) { double('mixpanel tracker') }
      let(:fake_mixpanel_data) { {} }

      before do
        allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
        allow(MixpanelService).to receive(:send_event)
      end

      it "sends intake_ids_uploaded event to Mixpanel" do
        get :edit

        expect(MixpanelService).to have_received(:send_event).with(
          distinct_id: intake.visitor_id,
          event_name: "intake_ids_uploaded",
          data: fake_mixpanel_data
        )

        expect(MixpanelService).to have_received(:data_from).with([intake.client, intake])
      end
    end
  end
end
