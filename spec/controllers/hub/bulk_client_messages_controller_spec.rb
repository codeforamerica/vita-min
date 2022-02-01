require "rails_helper"

RSpec.describe Hub::BulkClientMessagesController do
  let(:user) { create :organization_lead_user, organization: organization }
  let(:organization) { create :organization }

  describe "#show" do
    let!(:successful_client) { create :client_with_intake_and_return, vita_partner: organization, state: "file_efiled" }
    let!(:failed_client) { create :client_with_intake_and_return, vita_partner: organization, state: "file_efiled" }
    let!(:in_progress_client) { create :client_with_intake_and_return, vita_partner: organization, state: "file_efiled" }
    let!(:tax_return_selection) { create :tax_return_selection, tax_returns: [successful_client.tax_returns.first, failed_client.tax_returns.first] }
    let!(:bulk_client_message) { create :bulk_client_message, tax_return_selection: tax_return_selection }
    let(:message_status_param) { BulkClientMessage::SUCCEEDED }
    let(:params) do
      { id: bulk_client_message.id, status: message_status_param }
    end

    before do
      allow_any_instance_of(BulkClientMessage).to receive(:clients_with_no_successfully_sent_messages).and_return Client.where(id: failed_client)
      allow_any_instance_of(BulkClientMessage).to receive(:clients_with_successfully_sent_messages).and_return Client.where(id: successful_client)
      allow_any_instance_of(BulkClientMessage).to receive(:clients_with_in_progress_messages).and_return Client.where(id: in_progress_client)
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :show

    context "as an authenticated user" do
      before { sign_in user }

      context "with a 'failed' param" do
        let(:message_status_param) { BulkClientMessage::FAILED }
        it "only shows clients with messages that failed" do
          get :show, params: params

          expect(assigns(:clients)).to match_array [failed_client]
          expect(response).to be_ok
        end

        context "when the user cannot access all of the clients" do
          render_views
          let!(:inaccessible_client) { create :client_with_intake_and_return, state: "file_efiled" }
          let!(:tax_return_selection) { create :tax_return_selection, tax_returns: [successful_client.tax_returns.first, failed_client.tax_returns.first, inaccessible_client.tax_returns.first] }

          before do
            allow_any_instance_of(BulkClientMessage).to receive(:clients_with_no_successfully_sent_messages).and_return Client.where(id: [failed_client, inaccessible_client])
          end

          it "displays the correct help text" do
            get :show, params: params
            help_text = Nokogiri::HTML.parse(response.body).at_css("p.access-warning")
            expect(help_text).to have_text("1 result is no longer accessible to you.")
          end
        end
      end

      context "with a 'succeeded' param" do
        let(:message_status_param) { BulkClientMessage::SUCCEEDED }

        it "only shows clients with successfully sent messages" do
          get :show, params: params

          expect(assigns(:clients)).to match_array [successful_client]
          expect(response).to be_ok
        end
      end

      context "with an 'in-progress' param" do
        let(:message_status_param) { BulkClientMessage::IN_PROGRESS }

        it "only shows clients with in-progress messages" do
          get :show, params: params

          expect(assigns(:clients)).to match_array [in_progress_client]
          expect(response).to be_ok
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
end
