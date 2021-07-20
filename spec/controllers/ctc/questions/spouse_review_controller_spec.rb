require "rails_helper"

describe Ctc::Questions::SpouseReviewController do
  let(:intake) { create :ctc_intake, client: create(:client, tax_returns: [(create :tax_return, filing_status: "married_filing_jointly")]) }

  before do
    sign_in intake.client
  end

  it_behaves_like :a_question_where_an_intake_is_required, CtcQuestionNavigation

  describe "#edit" do
    render_views

    it "renders edit template" do
      get :edit, params: {}
      expect(response).to render_template :edit

      html = Nokogiri::HTML.parse(response.body)
      expect(html.at_css("a[href=\"#{questions_had_dependents_path}\"]")).to be_present
    end
  end
end