require 'rails_helper'

RSpec.describe Hub::BulkActions::ChangeOrganizationController do
  let(:organization) { create :organization }
  let(:tax_return_selection) { create :tax_return_selection }
  let(:user) { create :organization_lead_user, organization: organization }

  describe "#edit" do
    let(:params) { { tax_return_selection_id: tax_return_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in user }

      context "since most users can't assign to all vita partners" do
        let!(:site) { create :site, parent_organization: organization }
        let!(:other_site) { create :site, parent_organization: organization }
        let!(:external_org) { create :organization }
        let!(:external_site) { create :site, parent_organization: external_org }

        it "only shows accessible vita partners in the dropdown" do
          get :edit, params: params

          expect(assigns(:vita_partners)).to match_array [organization, site, other_site]
        end
      end
    end
  end

  describe "#update" do
    let(:new_vita_partner) { create :site, parent_organization: organization }
    let(:params) do
      {
        tax_return_selection_id: tax_return_selection.id,
        hub_bulk_action_form: {
          vita_partner_id: new_vita_partner.id
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      before { sign_in user }

      context "updating organization" do
        let!(:selected_client) { create :client, intake: (create :intake), vita_partner: organization, tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])] }

        it "updates the organization on all selected clients, creates the right record, and redirects to the notification page" do
          expect {
            put :update, params: params
          }.to change { selected_client.reload.vita_partner }.from(organization).to(new_vita_partner).and(
            change(BulkClientOrganizationUpdate, :count).by(1)
          ).and(
            change(UserNotification, :count).by(1)
          )

          bulk_update = BulkClientOrganizationUpdate.last
          expect(bulk_update.tax_return_selection).to eq tax_return_selection
          expect(bulk_update.user_notification.user).to eq user
          expect(bulk_update.user_notification.notifiable.vita_partner).to eq new_vita_partner

          expect(response).to redirect_to hub_user_notifications_path
        end

        context "when user only has access to update some clients" do
          let!(:inaccessible_selected_client) { create :client, intake: (create :intake), tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])], vita_partner: create(:organization) }

          it "only updates the clients that the user can access" do
            expect {
              put :update, params: params
            }.not_to change { inaccessible_selected_client.reload.vita_partner }
          end
        end

        context "when users are assigned to the returns and don't have access through the new partner" do
          let(:old_site) { create :site, parent_organization: organization }
          let(:assigned_user_at_old_site) { create :site_coordinator_user, site: old_site }
          let(:assigned_user_who_retains_access) { create :organization_lead_user, organization: organization }
          let(:selected_client) { create :client, intake: (create :intake), vita_partner: old_site}
          let!(:still_assigned_return) { create :tax_return, client: selected_client, assigned_user: assigned_user_who_retains_access, year: 2018, tax_return_selections: [tax_return_selection] }
          let!(:unassigned_return) { create :tax_return, client: selected_client, assigned_user: assigned_user_at_old_site, year: 2017, tax_return_selections: [tax_return_selection] }
          let!(:not_selected_return) { create :tax_return, client: selected_client, assigned_user: assigned_user_at_old_site, year: 2019 }

          it "unassigns all users who are losing access" do
            put :update, params: params

            expect(selected_client.reload.vita_partner).to eq new_vita_partner
            expect(assigned_user_at_old_site.reload.assigned_tax_returns).to be_empty
            expect(unassigned_return.reload.assigned_user).to eq nil
            expect(assigned_user_who_retains_access.reload.assigned_tax_returns).to eq [still_assigned_return]
          end
        end
      end

      context "sending messages" do
        let(:bulk_client_message) { create :bulk_client_message }
        before { allow(ClientMessagingService).to receive(:send_bulk_message).and_return(bulk_client_message) }

        context "with valid message params" do
          let(:english_message_body) { "I moved your case to a new org!" }
          let(:spanish_message_body) { "¡Mové su caso a una organización nueva!" }
          let(:params) do
            {
                tax_return_selection_id: tax_return_selection.id,
              hub_bulk_action_form: {
                vita_partner_id: new_vita_partner.id,
                message_body_en: english_message_body,
                message_body_es: spanish_message_body
              }
            }
          end

          before do
            allow_any_instance_of(Hub::BulkActionForm).to receive(:valid?).and_return true
          end

          it "calls the ClientMessagingService with the right arguments" do
            put :update, params: params

            expect(ClientMessagingService).to have_received(:send_bulk_message).with(
              tax_return_selection,
              user,
              en: english_message_body,
              es: spanish_message_body,
            )
          end

          it "creates a Notification for BulkClientMessage" do
            expect do
              put :update, params: params
            end.to change { UserNotification.where(notifiable_type: "BulkClientMessage").count }.by(1)

            bulk_message_notification = UserNotification.where(notifiable_type: "BulkClientMessage").last
            expect(bulk_message_notification.user).to eq(user)
            expect(bulk_message_notification.notifiable).to eq(bulk_client_message)
          end
        end

        context "with invalid message params" do
          before do
            allow_any_instance_of(Hub::BulkActionForm).to receive(:valid?).and_return false
          end

          it "does not enqueue a job" do
            put :update, params: params

            expect(ClientMessagingService).not_to have_received(:send_bulk_message)
          end
        end
      end

      context "creating a note" do
        let!(:selected_client_1) { create :client, intake: (create :intake), tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])], vita_partner: organization }
        let!(:selected_client_2) { create :client, intake: (create :intake), tax_returns: [(create :tax_return, tax_return_selections: [tax_return_selection])], vita_partner: organization }
        let(:note_body) { "An internal note with some text in it" }
        let(:params) do
          {
            tax_return_selection_id: tax_return_selection.id,
            hub_bulk_action_form: {
              vita_partner_id: new_vita_partner.id,
              note_body: note_body
            }
          }
        end

        it "saves a note and fires related after creation hooks" do
          expect {
            put :update, params: params
          }.to change(Note, :count).by(2).and(
            change { selected_client_1.reload.last_internal_or_outgoing_interaction_at }
          ).and(
            change(BulkClientNote, :count).by(1)
          ).and(
            change { UserNotification.where(notifiable_type: "BulkClientNote").count }.by(1)
          )

          expect(selected_client_1.notes.first.body).to eq note_body
          expect(selected_client_1.notes.first.user).to eq user
          expect(selected_client_2.notes.first.body).to eq note_body
          expect(selected_client_2.notes.first.user).to eq user

          bulk_note = BulkClientNote.last
          expect(bulk_note.tax_return_selection).to eq tax_return_selection
          expect(bulk_note.user_notification.user).to eq user
        end
      end
    end
  end
end
