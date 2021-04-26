require "rails_helper"

RSpec.describe Hub::ClientSelectionsController do
  let(:organization) { create :organization }
  let(:user) { create :organization_lead_user, organization: organization }
  let(:clients) { create_list :client_with_intake_and_return, 3, vita_partner: organization, status: "file_efiled" }
  let(:client_selection) { create :client_selection, clients: clients }

  describe "#show" do
    let(:params) { { id: client_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "as an authenticated user" do
      before { sign_in user }

      it "can see the right clients listed" do
        get :show, params: params

        expect(assigns(:clients)).to match_array clients
      end

      context "as a user who does not have access to all the clients in the client selection" do
        let(:site) { create :site, parent_organization: organization }
        let(:clients_for_org) { create_list :client_with_intake_and_return, 3, vita_partner: organization, status: "file_efiled" }
        let(:clients_for_site) { create_list :client_with_intake_and_return, 2, vita_partner: site, status: "file_efiled" }
        let(:user) { create :site_coordinator_user, site: site }
        let(:clients) { clients_for_org + clients_for_site }

        it "only shows the allowed clients" do
          get :show, params: params

          expect(assigns(:clients)).to match_array clients_for_site
        end

        it "shows a count of inaccessible clients" do
          get :show, params: params

          expect(assigns(:client_index_help_text)).to eq("You are viewing 2 results from your saved search")
          expect(assigns(:missing_results_message)).to eq "3 results are no longer accessible to you."
        end
      end

      context "when rendering" do
        render_views

        it "is ok, adds a short message and points the search form to the client index" do
          get :show, params: params

          expect(response).to be_ok
          html = Nokogiri::HTML.parse(response.body)
          expect(html.at_css(".filter-form")["action"]).to eq hub_clients_path
          expect(html.at_css(".count-wrapper .text--help").text.strip).to eq "You are viewing 3 results from your saved search"
        end
      end
    end
  end

  describe "#create" do
    let(:tax_return1) { create(:tax_return, client: clients[0], year: 2020) }
    let(:tax_return2) { create(:tax_return, client: clients[0], year: 2018) }
    let(:tax_return3) { create(:tax_return, client: clients[1], year: 2018) }
    let(:params) { { create_client_selection: { tr_ids: [tax_return1, tax_return2, tax_return3].map(&:id).map(&:to_s), action_type: action_type } } }
    let(:action_type) { "change-organization" }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before { sign_in user }

      context "when the action type is changing organization" do
        it "should create client_selection and redirect to the appropriate bulk action page for change-organization" do
          expect {
            post :create, params: params
          }.to change(ClientSelection, :count).by(1)

          client_selection = ClientSelection.last
          expect(client_selection.clients.count).to eq(2)
          expect(client_selection.clients).to match_array [clients[0], clients[1]]

          expect(response).to redirect_to(hub_bulk_actions_edit_change_organization_path(client_selection_id: client_selection.id))
        end
      end

      context "when the action type is sending a message" do
        let(:action_type) { "send-a-message" }

        it "should create client_selection and redirect to the appropriate bulk action page for send-a-message" do
          expect {
            post :create, params: params
          }.to change(ClientSelection, :count).by(1)

          client_selection = ClientSelection.last
          expect(client_selection.clients.count).to eq(2)
          expect(client_selection.clients).to match_array [clients[0], clients[1]]

          expect(response).to redirect_to(hub_bulk_actions_edit_send_a_message_path(client_selection_id: client_selection.id))
        end
      end


      context "if action_type is not properly set" do
        let(:params) { { create_client_selection: { tr_ids: [tax_return1, tax_return2, tax_return3].map(&:id).map(&:to_s), action_type: "not-a-valid-type" } } }

        it "should not be found" do
          expect {
            post :create, params: params
          }.to change(ClientSelection, :count).by(0)
          expect(response).to be_not_found
        end
      end

      context "with tax returns the user doesn't have access to" do
        let(:tax_return1) { create(:tax_return, client: clients[0], year: 2020) }
        let(:tax_return2) { create(:tax_return, client: clients[0], year: 2018) }
        let(:tax_return3) { create(:tax_return, client: create(:client), year: 2018) }
        let(:params) { { create_client_selection: { tr_ids: [tax_return1, tax_return2, tax_return3].map(&:id).map(&:to_s), action_type: "change-organization" } } }

        it "only selects clients that the user does have access to" do
          expect {
            post :create, params: params
          }.to change(ClientSelection, :count).by(1)

          client_selection = ClientSelection.last
          expect(client_selection.clients.count).to eq(1)
          expect(client_selection.clients).to match_array [clients[0]]
        end
      end
    end
  end

  describe "#new" do
    let(:tax_return1) { create(:tax_return, client: clients[0], year: 2020) }
    let(:tax_return2) { create(:tax_return, client: clients[0], year: 2018) }
    let(:tax_return3) { create(:tax_return, client: clients[1], year: 2018) }
    let(:params) { { tr_ids: [tax_return1, tax_return2, tax_return3].map(&:id).map(&:to_s) } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before { sign_in user }

      it "sets client count and is OK" do
        get :new, params: params

        expect(assigns(:client_count)).to eq 2
        expect(assigns(:tr_ids)).to eq params[:tr_ids]
        expect(response).to be_ok
      end
    end
  end
end
