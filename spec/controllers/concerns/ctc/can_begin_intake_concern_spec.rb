require "rails_helper"

describe Ctc::CanBeginIntakeConcern, type: :controller do
  describe "before actions" do
    controller(ApplicationController) do
      include Ctc::CanBeginIntakeConcern

      def index
        head :ok
      end
    end

    context "when open for intake" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:open_for_ctc_intake?).and_return true
      end

      it "lets you through" do
        get :index
        expect(response).to be_ok
      end
    end


    context "when not open for intake but the client is currently logged in so we let them continue" do
      let(:client) { create :client, intake: (create :ctc_intake) }

      before do
        allow_any_instance_of(ApplicationController).to receive(:open_for_ctc_intake?).and_return false
      end

      before do
        sign_in client
      end

      it "lets you through" do
        get :index
        expect(response).to be_ok
      end
    end
  end
end
