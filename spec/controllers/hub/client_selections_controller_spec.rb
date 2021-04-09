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
          expect(assigns(:missing_results_message)).to eq "3 results are no longer accessible to you"
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

  describe "#bulk_action" do
    let(:params) { { id: client_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :bulk_action

    context "as an authenticated user" do
      before { sign_in user }

      it "should set client_selection and return 200 OK" do
        get :bulk_action, params: params

        expect(assigns(:client_count)).to eq 3
        expect(response).to be_ok
      end
    end
  end
end
