require 'rails_helper'

RSpec.describe Hub::BulkActions::ChangeOrganizationController do
  describe "#edit" do
    let(:client_selection) { create :client_selection }
    let(:params) { { client_selection_id: client_selection.id } }
    let(:organization) { create :organization }
    let!(:site) { create :site, parent_organization: organization }
    let!(:other_site) { create :site, parent_organization: organization }
    let(:user) { create :organization_lead_user, organization: organization }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    # are we creating a new record?
    # do we need it? What's the output?
    # for message send, it def needs a record, but for others though?
    # how is client_selection being passed into this controller?
    context "as an authenticated user" do
      before { sign_in user }

      it "allows me to choose between all the orgs and sites I can access" do
        get :edit, params: params

        expect(assigns(:vita_partners)).to match_array([organization, site, other_site])
      end

      # authorization (define what happens for partial access)
      # listing exisitng org assignments
      # warning if clients don't have contact info
      # langauge inputs & client coutn for each (if language present in clients)
      # if we want any HTML front end properties for validating input length
      # if an assignee would lose access due to org cahnge, how do we tell that to the user? Assumption is they will lose access but do we need to communicate that more.

      context "client language" do
        it "sets a list of languages these clients need" do
          get :edit, params: params

          expect(assigns(:locales)).to match_array([organization, site, other_site])
        end

      end



    end
  end
end
