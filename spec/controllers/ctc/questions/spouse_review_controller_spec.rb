require "rails_helper"

describe Ctc::Questions::SpouseReviewController do
  let(:intake) { create :ctc_intake, client: create(:client, tax_returns: [(create :tax_return, filing_status: "married_filing_jointly")]) }

  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_ctc_clients_only, action: :edit

    context "as an authenticated ctc client" do
      before do
        sign_in intake.client
      end

      render_views

      it "includes a link to proceed to next_path" do
        get :edit, params: {}
        expect(response).to render_template :edit

        html = Nokogiri::HTML.parse(response.body)
        expect(html.at_css("a[href=\"#{questions_had_dependents_path}\"]")).to be_present
      end
    end
  end
end