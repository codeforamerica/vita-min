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
  end
end
