require "rails_helper"

RSpec.describe Documents::IntroController do
  render_views
  let(:attributes) { {} }
  let(:intake) { create :intake, intake_ticket_id: 1234, **attributes }

  before do
    allow(subject).to receive(:current_intake).and_return intake
  end

  describe "#edit" do
    context "with a set of answers on an intake" do
      let(:attributes) { { had_wages: "yes", had_retirement_income: "yes" } }

      it "shows section headers for the expected document types" do
        get :edit

        expect(response.body).to include("W-2")
        expect(response.body).to include("1099-R")
        expect(response.body).not_to include("Other")
        expect(response.body).not_to include("1099-MISC")
        expect(response.body).not_to include("1099-B")
      end
    end
  end
end
