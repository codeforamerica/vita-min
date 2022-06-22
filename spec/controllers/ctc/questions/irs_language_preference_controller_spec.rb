require "rails_helper"

describe Ctc::Questions::IrsLanguagePreferenceController do
  let(:irs_language_preference) { nil }
  let(:intake) { create :ctc_intake, irs_language_preference: irs_language_preference }

  describe "#edit" do
    before do
      sign_in intake.client
    end

    render_views

    context "without a saved language preference" do
      context "when the locale is spanish" do
        it "selects spanish" do
          get :edit, params: { locale: "es" }
          expect(response).to render_template :edit

          html = Nokogiri::HTML.parse(response.body)
          value = html.at_css('#ctc_irs_language_preference_form_irs_language_preference option[@selected="selected"]')['value']
          expect(value).to eq "spanish"
        end
      end

      context "when the locale is english" do
        it "selects english" do
          get :edit, params: { locale: "en" }
          expect(response).to render_template :edit

          html = Nokogiri::HTML.parse(response.body)
          value = html.at_css('#ctc_irs_language_preference_form_irs_language_preference option[@selected="selected"]')['value']
          expect(value).to eq "english"
        end
      end
    end

    context "with a saved irs language preference" do
      let(:irs_language_preference) { "russian" }

      it "selects the saved language" do
        get :edit, params: { locale: "en" }
        expect(response).to render_template :edit

        html = Nokogiri::HTML.parse(response.body)
        value = html.at_css('#ctc_irs_language_preference_form_irs_language_preference option[@selected="selected"]')['value']
        expect(value).to eq "russian"
      end
    end
  end
end