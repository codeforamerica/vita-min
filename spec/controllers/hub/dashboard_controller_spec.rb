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
      let(:vita_partner) { VitaPartner.first }
      before { sign_in user }
      render_views

<<<<<<< HEAD
      it "responds with ok" do
        model = VitaPartner.first
        get :show, params: { id: model.id, type: model.class.name.downcase }
        expect(response).to be_ok
=======
      it "sets instance variables and responds with ok" do
        get :show, params: { id: vita_partner.id, type: vita_partner.class.name.downcase }
        expect(response).to be_ok
        expect(assigns(:selected_value)).to eq "organization/#{vita_partner.id}"
        expect(assigns(:filter_options).length).to eq 1
        expect(assigns(:filter_options)[0].model).to eq vita_partner
      end

      it "shows the action required panel" do
        get :show, params: { id: vita_partner.id, type: vita_partner.class.name.downcase }
        expect(response.body).to have_text I18n.t('hub.dashboard.show.action_required.title')
        expect(response.body).to have_text I18n.t('hub.dashboard.show.action_required.client_name')
      end

      context "when there are flagged clients in the current product year" do
        let!(:first_intake) { create :intake, preferred_name: "Joanna", client: create(:client, flagged_at: Time.now, vita_partner: vita_partner)}
        let!(:second_intake) { create :intake, preferred_name: "Kinsley", client: create(:client, flagged_at: Time.now, vita_partner: vita_partner)}
        let!(:unflagged_intake) { create :intake, preferred_name: "Lava", client: create(:client, flagged_at: nil, vita_partner: vita_partner)}

        it "shows the flagged clients" do
          get :show, params: { id: vita_partner.id, type: vita_partner.class.name.downcase }
          expect(response.body).to have_text "Joanna"
          expect(response.body).to have_text "Kinsley"
          expect(response.body).not_to have_text "Lava"
        end
>>>>>>> main
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

    context "with an admin user" do
      let(:coalition) { create :coalition, name: "Montana" }
      let(:first_org) { create(:organization, coalition: coalition, name: "PawPaw") }
      let(:second_org) { create(:organization, coalition: coalition, name: "MeowWolf") }
      let(:site) { create(:site, parent_organization_id: first_org.id) }

      let!(:first_intake) { create :intake, preferred_name: "Juliet", client: create(:client, flagged_at: nil, vita_partner: first_org)}
      let!(:second_intake) { create :intake, preferred_name: "Romeo", client: create(:client, flagged_at: Time.now, vita_partner: first_org)}
      let!(:third_intake) { create :intake, preferred_name: "Benvolio", client: create(:client, flagged_at: Time.now, vita_partner: second_org)}
      let!(:fourth_intake) { create :intake, preferred_name: "William", client: create(:client, flagged_at: Time.now, vita_partner: site)}

      let!(:admin_user) { create :admin_user }

      before { sign_in admin_user }
      render_views

      context "when selecting the coalition" do
        let(:params) do
          {
            id: coalition.id,
            type: coalition.class.name.downcase
          }
        end
        it "shows only the flagged clients for that org and its child sites in the action required panel" do
          get :show, params: params
          expect(response.body).not_to have_text "Juliet"
          expect(response.body).to have_text "Romeo"
          expect(response.body).to have_text "Benvolio"
          expect(response.body).to have_text "William"
        end
      end

      context "when selecting an organization" do
        let(:params) do
          {
            id: first_org.id,
            type: first_org.class.name.downcase
          }
        end
        it "shows only the flagged clients from that site in the action required panel" do
          get :show, params: params
          expect(response.body).not_to have_text "Juliet"
          expect(response.body).to have_text "Romeo"
          expect(response.body).not_to have_text "Benvolio"
          expect(response.body).to have_text "William"
        end
      end

      context "when selecting a site" do
        let(:params) do
          {
            id: site.id,
            type: site.class.name.downcase
          }
        end
        it "shows only the flagged clients from that site in the action required panel" do
          get :show, params: params
          expect(response.body).not_to have_text "Juliet"
          expect(response.body).not_to have_text "Romeo"
          expect(response.body).not_to have_text "Benvolio"
          expect(response.body).to have_text "William"
        end
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


