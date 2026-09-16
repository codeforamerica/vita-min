require "rails_helper"

RSpec.describe Questions::BacktaxesController do
  let(:intake) { create :intake }

  before do
    allow(subject).to receive(:current_intake).and_return(intake)
  end

  render_views

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
        expect(intake.needs_help_previous_year_1).to eq "no"
        expect(intake.needs_help_current_year).to eq "yes"
      end
    end

    context "routing the client when routing service returns nil and routing_method is at_capacity" do
      let!(:organization_router) { double }
      let(:params) do
        {
          backtaxes_form: {
            needs_help_previous_year_3: "no",
            needs_help_previous_year_2: "no",
            needs_help_previous_year_1: "yes",
            needs_help_current_year: "no"
          }
        }
      end

      before do
        allow(PartnerRoutingService).to receive(:new).and_return organization_router
        allow(organization_router).to receive(:determine_partner).and_return nil
        allow(organization_router).to receive(:routing_method).and_return :at_capacity
      end

      it "saves routing method to at capacity, does not set a vita partner, and redirects to the at capacity page" do
        post :update, params: params

        expect(intake.client.reload.routing_method).to eq("at_capacity")
        expect(intake.client.vita_partner).to eq nil
        expect(PartnerRoutingService).to have_received(:new).with(
          {
            intake: intake,
            source_param: intake.source,
            zip_code: intake.zip_code
          }
        )
        expect(organization_router).to have_received(:determine_partner)
        expect(response).to redirect_to Questions::AtCapacityController.to_path_helper
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
