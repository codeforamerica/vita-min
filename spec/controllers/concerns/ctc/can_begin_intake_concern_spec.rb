require "rails_helper"

describe Ctc::CanBeginIntakeConcern, type: :controller do
  describe "before actions" do
    controller(ApplicationController) do
      include Ctc::CanBeginIntakeConcern

      def index
        head :ok
      end
    end

    context "on non-production environments" do
      before do
        allow(Rails.env).to receive(:production?).and_return(false)
      end

      it "lets everyone through" do
        get :index
        expect(response).to be_ok
      end
    end

    context "on a production environment" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      context "with the required cookie" do
        before do
          cookies[:ctc_intake_ok] = "yes"
        end

        it "lets you through" do
          get :index
          expect(response).to be_ok
        end
      end

      context "without the required cookie" do
        it "shows page not found" do
          expect {
            get :index
          }.to raise_error(ActionController::RoutingError)
        end
      end
    end
  end
end
