require "rails_helper"

describe Questions::AnonymousIntakeController, type: :controller do
  let(:intake) { create :intake }

  context "with an inheriting child controller" do
    controller(Questions::AnonymousIntakeController) do
      def index
        head :ok
      end
    end

    before { allow(subject).to receive(:current_intake).and_return(intake) }

    it "sets @show_client_sign_in_link" do
      get :index

      expect(assigns(:show_client_sign_in_link)).to eq true
    end
  end
end