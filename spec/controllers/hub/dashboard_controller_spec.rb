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

      context "with a nested set of Coalitions and Organizations" do
        let(:coalition) { create :coalition }
        let(:user) { create(:user, role: create(:coalition_lead_role, coalition: coalition)) }
        let(:orgs) do
          [
            create(:organization, coalition: coalition),
            create(:organization, coalition: coalition),
            create(:organization, coalition: coalition)
          ]
        end

        it "sets filter options correctly" do
          expected_filter_options = [
            "coalition/#{coalition.id}",
            "organization/#{orgs[0].id}",
            "organization/#{orgs[1].id}",
            "organization/#{orgs[2].id}"
          ]
          get :index
          expect(assigns(:filter_options).length).to eq 4
          expect(assigns(:filter_options).map{|option| option.value }).to eq expected_filter_options
        end
      end
    end
  end

  describe "#show" do

    context "with an authorized user" do
      let(:vita_partner) { VitaPartner.first }
      before { sign_in user }
      render_views

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

      it "shows the resources panel" do
        model = VitaPartner.first
        get :show, params: { id: model.id, type: model.class.name.downcase }
        expect(response.body).to have_text I18n.t('hub.dashboard.show.resources.title')
        expect(response.body).to have_text I18n.t('hub.dashboard.show.resources.newsletter')
      end
    end
  end
end


