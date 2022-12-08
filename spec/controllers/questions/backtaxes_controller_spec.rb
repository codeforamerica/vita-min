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

      # TODO(TY2022): Support 2022
      expect(assigns(:possible_filing_years)).to eq (MultiTenantService.new(:gyr).filing_years)
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
            needs_help_previous_year_3: "yes",
            needs_help_previous_year_2: "yes",
            needs_help_previous_year_1: "no",
            needs_help_current_year: "yes"
          }
        }
      end

      it "saves answers to the intake" do
        post :update, params: params

        expect(intake.needs_help_previous_year_3).to eq "yes"
        expect(intake.needs_help_previous_year_2).to eq "yes"
        expect(intake.needs_help_current_year).to eq "yes"
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_previous_year_3: "no",
            needs_help_previous_year_2: "no",
            needs_help_previous_year_1: "no",
            needs_help_current_year: "no"
          }
        }
      end

      it "renders edit with validation error" do
        post :update, params: params

        expect(response).to render_template(:edit)
        expect(response).to be_ok
        expect(response.body).to include "Please pick at least one year."
      end
    end
  end
end
