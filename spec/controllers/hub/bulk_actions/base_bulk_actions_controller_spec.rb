require 'rails_helper'

RSpec.describe Hub::BulkActions::BaseBulkActionsController do
  let(:client_selection) { create :client_selection }
  let(:organization) { create :organization }
  let(:user) { create :organization_lead_user, organization: organization }

  controller do
    def edit
      head :ok
    end
  end

  before do
    routes.draw do
      namespace :hub do
        namespace :bulk_actions do
          get "/:client_selection_id/edit" => "base_bulk_actions#edit"
        end
      end
    end
  end

  describe "#edit" do
    let(:params) { { client_selection_id: client_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in user }

      context "before_actions" do
        let(:bulk_action_form) { instance_double(Hub::BulkActionForm) }

        before do
          allow(Hub::BulkActionForm).to receive(:new).and_return(bulk_action_form)
        end

        it "loads the form" do
          get :edit, params: params

          expect(Hub::BulkActionForm).to have_received(:new).with(client_selection)
          expect(assigns(:form)).to eq(bulk_action_form)
        end

        context "when the user cannot access all the selected clients" do
          let(:inaccessible_org) { create :organization }
          let!(:accessible_client) { create :client_with_intake_and_return, client_selections: [client_selection], vita_partner: organization }
          let!(:inaccessible_client) { create :client_with_intake_and_return, client_selections: [client_selection], vita_partner: inaccessible_org }

          it "sets @inaccessible_client_count" do
            get :edit, params: params
            expect(assigns(:client_selection).clients.count).to eq(2)
            expect(assigns(:inaccessible_client_count)).to eq(1)
          end

          it "only uses the accessible clients when computing locale count" do
            get :edit, params: params
            expect(assigns(:locale_counts).values.sum).to eq(1)
          end
        end

        context "with only clients who don't have sufficient contact info" do
          before do
            client = create :client, vita_partner: organization, client_selections: [client_selection]
            create :intake, client: client, email_notification_opt_in: "yes", email_address: nil, sms_notification_opt_in: "yes", sms_phone_number: nil
          end

          it "shows a message to the user with number of clients who have no contact info for their preferences" do
            get :edit, params: params

            expect(assigns(:no_contact_info_count)).to eq(1)
          end

          it "excludes them from locale_counts" do
            get :edit, params: params

            expect(assigns(:locale_counts).values.sum).to eq(0)
          end
        end
      end
    end
  end
end
