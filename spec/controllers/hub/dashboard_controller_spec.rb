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

      it "responds with ok" do
        model = VitaPartner.first
        get :show, params: { id: model.id, type: model.class.name.downcase }
        expect(response).to be_ok
      end

      it "shows the capacity panel" do
        model = VitaPartner.first
        get :show, params: { id: model.id, type: model.class.name.downcase }
        expect(response.body).to have_text I18n.t('hub.dashboard.show.capacity')
        expect(response.body).to have_text I18n.t('hub.dashboard.show.org_name')
        expect(response.body).to have_text Organization.first.name
        # Count instances of substring - note: string.count doesn't do this!
        expect(response.body.scan(/organization-link/).length).to eq(1)
      end

      it "shows the returns by status panel" do
        model = VitaPartner.first
        get :show, params: { id: model.id, type: model.class.name.downcase }
        expect(response.body).to have_text I18n.t('hub.dashboard.show.returns_by_status')
        expect(response.body.scan(/<div class=\"bar\" style=\"width:0%;\" title=\"0%\"><\/div>/).length).to eq(4)
      end

      it "shows the resources panel" do
        model = VitaPartner.first
        get :show, params: { id: model.id, type: model.class.name.downcase }
        expect(response.body).to have_text I18n.t('hub.dashboard.show.resources.title')
        expect(response.body).to have_text I18n.t('hub.dashboard.show.resources.newsletter')
      end
    end
  end

  describe "#returns_by_status" do
    before do
      tax_return = create(:gyr_tax_return, :intake_in_progress, updated_at: 10.days.ago, assigned_user: user)
      tax_return.client.update(vita_partner: VitaPartner.first)
      sign_in user
    end
    render_views

    it "renders the returns by status container with a single bar that is 100% of width" do
      model = VitaPartner.first
      get(
        :returns_by_status,
        params: { id: model.id, type: model.class.name.downcase, stage: "intake" },
        format: :js,
        xhr: true
      )
      # Has width:100% and title="100%"
      expect(response.body.scan(/100%/).length).to eq(2)
    end

  end
end


