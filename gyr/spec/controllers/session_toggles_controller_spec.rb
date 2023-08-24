require "rails_helper"

describe SessionTogglesController do
  describe "#index" do
    context "when rails environment is not production" do
      it "does not require login" do
        get :index
        expect(response.status).to eq 200
      end
    end

    context 'when rails environment is production' do
      before do
        allow(Rails.env).to receive(:production?).and_return true
      end

      it_behaves_like :a_get_action_for_authenticated_users_only, action: :index
    end
  end
end