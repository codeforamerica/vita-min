require "rails_helper"

describe Ctc::Questions::IrsLanguagePreferenceController do
  let(:irs_language_preference) { nil }
  let(:intake) { create :ctc_intake, irs_language_preference: irs_language_preference }

  describe "#edit" do
    before do
      sign_in intake.client
    end

    render_views

    context "locale is es and irs_language_preference is nil" do
      it "Spanish is selected" do
        get :edit, params: { locale: "es" }
        expect(response).to render_template :edit

        html = Nokogiri::HTML.parse(response.body)
        value = html.at_css('#ctc_irs_language_preference_form_irs_language_preference option[@selected="selected"]')['value']
        expect(value).to eq "spanish"
      end
    end

    context "locale is en and irs_language_preference is nil" do
      it "English is selected" do
        get :edit, params: { locale: "en" }
        expect(response).to render_template :edit

        html = Nokogiri::HTML.parse(response.body)
        value = html.at_css('#ctc_irs_language_preference_form_irs_language_preference option[@selected="selected"]')['value']
        expect(value).to eq "english"
      end
    end

    context "irs_language_preference is russian" do
      let(:irs_language_preference) { "russian" }

      it "Russian is selected" do
        get :edit, params: { locale: "en" }
        expect(response).to render_template :edit

        html = Nokogiri::HTML.parse(response.body)
        value = html.at_css('#ctc_irs_language_preference_form_irs_language_preference option[@selected="selected"]')['value']
        expect(value).to eq "russian"
      end
    end
  end
end