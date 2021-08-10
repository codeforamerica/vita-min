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
    let(:params) do
      {
        id: efile_error.id,
        efile_error: {
            expose: false,
            description_en: "<div>We were unable to verify your address. Can you check to see if there are any mistakes?</div>",
            description_es: "<div>We were unable to verify your address. Can you check to see if there are any mistakes? (In spanish)</div>",
            resolution_en: "<div>Here's how you can fix it.</div>",
            resolution_es: "<div>Here's how you can fix it. (in spanish)</div>"
        }
      }
    end

    it_behaves_like :an_action_for_admins_only, action: :update, method: :put

    context "as an authenticated user" do
      before do
        sign_in user
      end

      it "updates the object based on passed params" do
        expect(efile_error.expose).to eq true
        put :update, params: params
        efile_error.reload
        expect(efile_error.expose).to eq false
        expect(efile_error.description_en.body).to be_an_instance_of ActionText::Content
        expect(efile_error.description_en.body.to_s).to include "<div>We were unable to verify your address. Can you check to see if there are any mistakes?</div>"
        expect(response).to redirect_to hub_efile_error_path(id: efile_error.id)
      end
    end
  end
end