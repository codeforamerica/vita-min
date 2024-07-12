require "rails_helper"

RSpec.describe Hub::DashboardController do
  let!(:organization) { create :organization, allows_greeters: false }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization), timezone: "America/Los_Angeles") }

  describe "#index" do
    it_behaves_like :a_get_action_for_authenticated_users_only, action: :index

    context "with an authorized user" do
      before { sign_in user }
      render_views

      it "redirects to the show page for the first available model" do
        get :index
        model = VitaPartner.first
        expect(response).to redirect_to "/en/hub/dashboard/#{model.class.name.downcase}/#{model.id}"
      end
    end
  end

  describe "#show" do

    context "with an authorized user" do
      before { sign_in user }
      render_views

      it "sets instance variables and responds with ok" do
        model = VitaPartner.first
        get :show, params: { id: model.id, type: model.class.name.downcase }
        expect(response).to be_ok
        expect(assigns(:selected_value)).to eq "organization/#{model.id}"
        expect(assigns(:filter_options).length).to eq 1
        expect(assigns(:filter_options)[0].model).to eq model
      end

      it "shows the capacity panel" do
        model = VitaPartner.first
        get :show, params: { id: model.id, type: model.class.name.downcase }
        expect(response.body).to have_text I18n.t('hub.dashboard.show.capacity')
        expect(response.body).to have_text I18n.t('hub.dashboard.show.org_name')
        expect(response.body).to have_text "Organization 4"
        # Count instances of substring - note: string.count doesn't do this!
        expect(response.body.scan(/organization-link/).length).to eq(1)
      end
    end
  end
end


