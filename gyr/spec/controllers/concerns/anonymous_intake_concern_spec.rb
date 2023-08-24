require "rails_helper"

describe AnonymousIntakeConcern, type: :controller do
  describe "before actions" do
    controller(ApplicationController) do
      include AnonymousIntakeConcern

      def index
        head :ok
      end
    end

    let(:intake) { create :intake }
    before { allow(subject).to receive(:current_intake).and_return(intake) }

    it "sets @show_client_sign_in_link" do
      get :index

      expect(assigns(:show_client_sign_in_link)).to eq true
    end
  end
end