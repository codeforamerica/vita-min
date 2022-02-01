require "rails_helper"

RSpec.describe Hub::TaxReturnSelectionsController do
  let(:organization) { create :organization }
  let(:user) { create :organization_lead_user, organization: organization }
  let(:clients) { create_list :client_with_intake_and_return, 3, vita_partner: organization, state: "file_efiled" }

  describe "#show" do
    let(:tax_return_selection) { create :tax_return_selection, tax_returns: TaxReturn.joins(:client).where(clients: { id: clients}) }
    let(:params) { { id: tax_return_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "as an authenticated user" do
      before { sign_in user }

      it "can see the right clients listed" do
        get :show, params: params

        expect(assigns(:clients)).to match_array clients
      end

      context "as a user who does not have access to all the clients in the client selection" do
        let(:site) { create :site, parent_organization: organization }
        let(:clients_for_org) { create_list :client_with_intake_and_return, 3, vita_partner: organization, state: "file_efiled" }
        let(:clients_for_site) { create_list :client_with_intake_and_return, 2, vita_partner: site, state: "file_efiled" }
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

      context "message summaries" do
        let(:fake_message_summaries) { {} }

        before do
          allow(RecentMessageSummaryService).to receive(:messages).and_return(fake_message_summaries)
        end

        it "assigns message_summaries" do
          get :show, params: params
          expect(assigns(:message_summaries)).to eq(fake_message_summaries)
          expect(RecentMessageSummaryService).to have_received(:messages).with(assigns(:clients).map(&:id))
        end
      end
    end
  end

  describe "#create" do
    let(:tax_return1) { clients[0].tax_returns.find_by(year: 2021) }
    let(:tax_return2) { create(:tax_return, client: clients[0], year: 2018) }
    let(:tax_return3) { create(:tax_return, client: clients[1], year: 2018) }
    let(:params) { { create_tax_return_selection: { tr_ids: [tax_return1, tax_return2, tax_return3].map(&:id).map(&:to_s), action_type: action_type } } }
    let(:action_type) { "change-organization" }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before { sign_in user }

      context "when the action type is changing organization" do
        it "should create tax_return_selection and redirect to the appropriate bulk action page for change-organization" do
          expect {
            post :create, params: params
          }.to change(TaxReturnSelection, :count).by(1)

          selection = TaxReturnSelection.last
          expect(selection.tax_returns.count).to eq(3)
          expect(selection.clients).to match_array [clients[0], clients[1]]

          expect(response).to redirect_to(hub_bulk_actions_edit_change_organization_path(tax_return_selection_id: selection.id))
        end
      end

      context "when the action type is sending a message" do
        let(:action_type) { "send-a-message" }

        it "should create client_selection and redirect to the appropriate bulk action page for send-a-message" do
          expect {
            post :create, params: params
          }.to change(TaxReturnSelection, :count).by(1)

          selection = TaxReturnSelection.last
          expect(selection.tax_returns.count).to eq(3)
          expect(selection.clients).to match_array [clients[0], clients[1]]

          expect(response).to redirect_to(hub_bulk_actions_edit_send_a_message_path(tax_return_selection_id: selection.id))
        end
      end

      context "if action_type is not properly set" do
        let(:params) { { create_tax_return_selection: { tr_ids: [tax_return1, tax_return2, tax_return3].map(&:id).map(&:to_s), action_type: "not-a-valid-type" } } }

        it "should not be found" do
          expect {
            post :create, params: params
          }.to change(TaxReturnSelection, :count).by(0)
          expect(response).to be_not_found
        end
      end

      context "with tax returns the user doesn't have access to" do
        let(:tax_return1) { clients[0].tax_returns.find_by(year: 2021) }
        let(:tax_return2) { create(:tax_return, client: clients[0], year: 2018) }
        let(:tax_return3) { create(:tax_return, client: create(:client), year: 2018) }
        let(:params) { { create_tax_return_selection: { tr_ids: [tax_return1, tax_return2, tax_return3].map(&:id).map(&:to_s), action_type: "change-organization" } } }

        it "only selects tax returns that the user has access to" do
          expect {
            post :create, params: params
          }.to change(TaxReturnSelection, :count).by(1)

          tax_return_selection = TaxReturnSelection.last
          expect(tax_return_selection.tax_returns).to match_array [tax_return1, tax_return2]
          expect(tax_return_selection.clients).to match_array [clients[0]]
        end
      end
    end
  end

  describe "#new" do
    let!(:clients) { create_list :client_with_intake_and_return, 30, vita_partner: organization, state: "file_efiled" }
    let!(:client_other_org) { create :client, vita_partner: create(:organization) }
    let!(:tax_return1) { create(:tax_return, client: clients[0], year: 2019) }
    let!(:tax_return2) { create(:tax_return, client: clients[0], year: 2018) }
    let!(:tax_return3) { create(:tax_return, client: clients[1], year: 2018) }
    let(:params) { { tr_ids: [tax_return1, tax_return2, tax_return3].map(&:id).map(&:to_s) } }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :create

    context "as an authenticated user" do
      before { sign_in user }

      it "sets client count and tax return count and is OK" do
        get :new, params: params

        expect(assigns(:client_count)).to eq 2
        expect(assigns(:tax_return_count)).to eq 3
        expect(assigns(:tr_ids)).to eq params[:tr_ids]
        expect(response).to be_ok
      end

      context "given filtering params" do
        let(:params) do
          {
            vita_partner_id: organization.id,
            create_tax_return_selection: {
              action_type: "all-filtered-clients"
            }
          }
        end

        it "sets client count and tax return count and is OK" do
          get :new, params: params

          expect(assigns(:tr_ids)).to match_array(TaxReturn.where(client: Client.where(vita_partner: organization)).pluck(:id))
          expect(assigns(:client_count)).to eq 30
          expect(assigns(:tax_return_count)).to eq 33
        end
      end
    end
  end
end
