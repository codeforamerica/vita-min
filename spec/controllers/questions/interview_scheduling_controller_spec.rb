require "rails_helper"

RSpec.describe Questions::InterviewSchedulingController do
  render_views

  let(:intake) { create :intake }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "defaults the preferred language to select to the current locale" do
      get :edit, params: { locale: :es }

      expect(response.body).to have_select(
        I18n.t("views.questions.interview_scheduling.interview_preference", locale: :es),
        selected: "Español"
      )

      expect(response.body).to have_select(
         I18n.t("views.questions.interview_scheduling.written_preference", locale: :es),
         selected: "Español"
       )
    end

    context "when the intake has preferred language" do
      before { intake.update(preferred_interview_language: :en, preferred_written_language: "en") }

      it "defers to the intake preferred language" do
        get :edit, params: { locale: :es }
        expect(response.body).to have_select(
          I18n.t("views.questions.interview_scheduling.interview_preference", locale: :es),
          selected: "Inglés"
        )
        expect(response.body).to have_select(
           I18n.t("views.questions.interview_scheduling.written_preference", locale: :es),
           selected: "Inglés"
         )
      end
    end

    context "routing the client when routing service returns nil and routing_method is at_capacity" do
      let!(:organization_router) { double }
      let(:params) do
        {
          interview_scheduling_form: {
            interview_timing_preference: "After 11am, before 6pm",
            preferred_interview_language: "es",
            preferred_written_language: "en"
          }
        }
      end

      before do
        allow(PartnerRoutingService).to receive(:new).and_return organization_router
        allow(organization_router).to receive(:determine_partner).and_return nil
        allow(organization_router).to receive(:routing_method).and_return :at_capacity
      end

      it "saves routing method to at capacity, does not set a vita partner, does not create tax returns" do
        post :update, params: params

        intake = Intake.last
        expect(intake.client.routing_method).to eq("at_capacity")
        expect(intake.client.vita_partner).to eq nil
        expect(PartnerRoutingService).to have_received(:new).with(
          {
            intake: intake,
            source_param: intake.source,
            zip_code: intake.zip_code
          }
        )
        expect(organization_router).to have_received(:determine_partner)
        expect(intake.tax_returns.count).to eq 0
        expect(response).to redirect_to Questions::AtCapacityController.to_path_helper
      end
    end
  end
end
