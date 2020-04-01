require "rails_helper"

RSpec.describe Questions::BacktaxesController do
  render_views

  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2016: "no",
            needs_help_2017: "yes",
            needs_help_2018: "yes",
            needs_help_2019: "yes",
          }
        }
      end

      it "updates the intake" do
        post :update, params: params

        expect(intake.needs_help_2016).to eq "no"
        expect(intake.needs_help_2017).to eq "yes"
        expect(intake.needs_help_2018).to eq "yes"
        expect(intake.needs_help_2019).to eq "yes"
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          backtaxes_form: {
            needs_help_2016: "no",
            needs_help_2017: "no",
            needs_help_2018: "no",
            needs_help_2019: "no",
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
