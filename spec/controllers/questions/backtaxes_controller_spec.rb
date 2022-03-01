require "rails_helper"

RSpec.describe Questions::BacktaxesController do
  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  render_views

  describe "#load_possible_filing_years" do
    it "sets possible_filing_years to all filing years" do
      get :edit

      expect(assigns(:possible_filing_years)).to eq TaxReturn.filing_years
    end
  end

  describe "#edit" do
    it "renders the edit page" do
      get :edit

      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2018: "yes",
            needs_help_2019: "yes",
            needs_help_2020: "no",
            needs_help_2021: "yes"
          }
        }
      end

      it "saves answers to the intake" do
        post :update, params: params

        expect(intake.needs_help_2018).to eq "yes"
        expect(intake.needs_help_2019).to eq "yes"
        expect(intake.needs_help_2021).to eq "yes"
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2018: "no",
            needs_help_2019: "no",
            needs_help_2020: "no",
            needs_help_2021: "no"
          }
        }
      end

      it "renders edit with validation error" do
        post :update, params: params

        expect(response).to render_template(:edit)
        expect(response.body).to include "Please pick at least one year."
      end
    end
  end
end
