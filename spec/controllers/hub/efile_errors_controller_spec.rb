require "rails_helper"

describe Hub::EfileErrorsController do
  let(:user) { create :admin_user }
  describe "#index" do
    it_behaves_like :an_action_for_admins_only , action: :index, method: :get

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "renders index" do
        get :index

        expect(response).to render_template :index
        expect(assigns(:efile_errors)).to eq EfileError.all
      end
    end
  end

  describe "#edit" do
    let(:efile_error) { create :efile_error }
    let(:params) { { id: efile_error.id } }

    it_behaves_like :an_action_for_admins_only , action: :edit, method: :get
    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "renders edit" do
        get :edit, params: params
        expect(assigns(:efile_error)).to eq efile_error
        expect(response).to render_template :edit
      end
    end
  end

  describe "#update" do
    let(:efile_error) { create :efile_error }
    let(:params) { {
        id: efile_error.id,
        efile_error: { expose: false }
    } }

    it_behaves_like :an_action_for_admins_only , action: :update, method: :put

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "updates the object based on passed logic" do
        expect(efile_error.expose).to eq true
        put :update, params: params
        expect(efile_error.reload.expose).to eq false
        expect(response).to redirect_to hub_efile_errors_path
      end
    end
  end
end