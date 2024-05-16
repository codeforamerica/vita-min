require "rails_helper"

RSpec.describe PublicPagesController do
  render_views

  describe "#home" do
    let(:demo_banner_text) { I18n.t('views.shared.environment_warning.banner') }
    # let!(:first_category) { create(:faq_category, name_en: 'Vegetable Questions', position: 1)}
    # let!(:top_faq_1) do
    #   create(:faq_item, faq_category: first_category, question_en: 'How do I get the stimulus payments?', position: 1)
    # end
    # let!(:top_faq_2) do
    #   create(:faq_item, faq_category: first_category, question_en: 'What are the potantial benefits of filing a tax return?', position: 2)
    # end
    # let!(:top_faq_3) do
    #   create(:faq_item, faq_category: first_category, question_en: 'Am I a nonfiler?', position: 3)
    # end

    describe "common questions" do
      let(:last_common_question) { create(:faq_item) }
      let(:first_common_question) { create(:faq_item) }

      before do
        FaqQuestionGroupItem.create(group_name: 'home_page', position: 2, faq_item: last_common_question)
        FaqQuestionGroupItem.create(group_name: 'home_page', position: 1, faq_item: first_common_question)
      end

      it "shows the top questions in the 'home_page' group" do
        get :home

        expect(assigns(:common_questions)).to eq([first_common_question, last_common_question])
      end
    end

    context "in production" do
      before do
        allow(Rails).to receive(:env).and_return("production".inquiry)
      end

      it "does NOT show a banner warning that this is an example site" do
        get :home

        expect(response.body).not_to include(demo_banner_text)
      end

      it "includes GA script in html" do
        get :home

        expect(response.body).to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end

      context "when the app is open for intake" do
        it "links to the first question path for digital intake" do
          get :home

          expect(response.body).to include I18n.t('general.get_started')
          expect(response.body).to include question_path(:id => Questions::TriagePersonalInfoController)
        end
      end

      context "when the app is not open for gyr intake" do
        before do
          allow(subject).to receive(:open_for_gyr_intake?).and_return(false)
        end

        it "links to the first question path for digital intake" do
          get :home

          expect(response.body).not_to include I18n.t('general.get_started')
          expect(response.body).not_to include question_path(:id => Navigation::GyrQuestionNavigation.first)
        end
      end

      context "when the app is not open for state file intakes" do
        let(:past) { 1.day.ago }
        before do
          allow(Rails.application.config).to receive(:state_file_end_of_in_progress_intakes).and_return(past)
        end

        it "hides link to direct file" do
          get :home

          expect(response.body).not_to include I18n.t('views.shared.service_comparison.services.direct_file.cta')
        end
      end
    end

    context "in demo env" do
      before do
        allow(Rails).to receive(:env).and_return("demo".inquiry)
      end

      it "shows a banner warning that this is an example site" do
        get :home

        expect(response.body).to include(demo_banner_text)
        expect(response.body).to include("https://www.getyourrefund.org")
      end

      it "does not include google analytics" do
        get :home
        expect(response.body).not_to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end
    end

    context "in development env" do
      before do
        allow(Rails).to receive(:env).and_return("development".inquiry)
      end

      it "does not include google analytics" do
        get :home
        expect(response.body).not_to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end
    end

    context "in test env" do
      before do
        allow(Rails).to receive(:env).and_return("test".inquiry)
      end

      it "does not include google analytics" do
        get :home
        expect(response.body).not_to include "https://www.googletagmanager.com/gtag/js?id=UA-156157414-1"
      end
    end
  end

  describe "#stimulus" do
    it "redirects to the beginning of intake" do
      get :stimulus

      expect(response).to redirect_to Questions::WelcomeController.to_path_helper
    end
  end

  describe "#full-service" do
    it "redirects to the first intake page after triage and sets session source" do
      get :full_service

      expect(session[:source]).to eq "full-service"
      expect(response).to redirect_to Questions::EnvironmentWarningController.to_path_helper
    end
  end

  describe "#healthcheck" do
    it "renders the same content as the home page" do
      get :healthcheck
      expect(response).to be_ok
      expect(response.body).to include I18n.t("views.public_pages.home.header")
    end

    it "is not instrumented by Mixpanel" do
      allow(MixpanelService).to receive(:send_event)
      get :healthcheck
      expect(MixpanelService).not_to have_received(:send_event)
    end
  end

  describe "#home with source param" do
    context "when it can find a matching source parameter" do
      let(:source_parameter) { create :source_parameter, vita_partner: (create :organization, name: "Oregano Organization") }

      it "renders the home template with a welcome message" do
        get :home, params: { source: source_parameter.code }
        expect(flash[:notice]).to eq "Thanks for visiting via Oregano Organization!"
        expect(response).to redirect_to :root
      end

      it "sets the used_unique_link cookie" do
        get :home, params: { source: source_parameter.code }
        expect(cookies[:used_unique_link]).to eq("yes")
      end
    end

    context "when there is no matching source parameter" do
      it "redirects to home" do
        get :home, params: { source: "no-match" }
        expect(response).to redirect_to :root
      end

      it "does not set the used_unique_link cookie" do
        get :home, params: { source: "no-match" }
        expect(cookies[:used_unique_link]).to be_nil
      end
    end

    context "when there is an inactive matching source parameter" do
      let(:source_parameter) { create :source_parameter, active: false, vita_partner: (create :organization, name: "Oregano Organization") }

      it "redirects to home" do
        get :home, params: { source: source_parameter.code }
        expect(response).to redirect_to :root
        expect(flash[:notice]).to eq "Unique URL is not in use."
      end

      it "does not set the used_unique_link cookie" do
        get :home, params: { source: source_parameter.code }
        expect(cookies[:used_unique_link]).to be_nil
      end
    end
  end

  describe "#privacy_policy" do
    it "renders successfully" do
      get :privacy_policy
      expect(response).to be_ok
    end
  end

  describe "#volunteers" do
    render_views

    it "renders the content" do
      get :volunteers

      expect(response.body).to include "GetYourRefund - Volunteer Signup"
    end
  end
end
