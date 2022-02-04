require 'rails_helper'

RSpec.describe Hub::BulkActions::ChangeAssigneeAndStatusController do
  let(:client) { create :client, vita_partner: site, intake: create(:intake) }
  let(:site) { create :site }
  let(:organization) { create :organization }

  let!(:team_member) { create :user, role: create(:team_member_role, site: site) }
  let!(:site_coordinator) { create :user, role: create(:site_coordinator_role, site: site) }
  let!(:inaccessible_user) { create :user }

  let(:tax_return_1) { create :tax_return, :file_ready_to_file, assigned_user: team_member, client: client, year: 2021 }
  let(:tax_return_2) { create :tax_return, :review_signature_requested, assigned_user: team_member, client: client, year: 2019 }
  let(:tax_return_3) { create :tax_return, :review_signature_requested, assigned_user: site_coordinator, client: client, year: 2018 }
  let(:unselected_tax_return) { create :tax_return, :file_efiled, assigned_user: team_member }
  let!(:tax_return_selection) { create :tax_return_selection, tax_returns: [tax_return_1, tax_return_2, tax_return_3] }

  describe "#edit" do
    let(:params) { { tax_return_selection_id: tax_return_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in team_member }

      it "tr_statues only includes current statuses of selected tax returns" do
        get :edit, params: params

        expect(assigns(:current_tr_statuses)).to match_array ["file_ready_to_file", "review_signature_requested"]
        expect(assigns(:current_tr_statuses)).not_to include unselected_tax_return.current_state
      end

      it "assignable users only includes accessible users" do
        get :edit, params: params

        expect(assigns(:assignable_users)).to match_array [team_member, site_coordinator]
        expect(assigns(:assignable_users)).not_to include inaccessible_user
      end
    end
  end

  describe "#update" do
    let(:new_status) { "review_ready_for_call" }
    let(:new_assigned_user_id) { site_coordinator.id }
    let(:params) do
      {
        tax_return_selection_id: tax_return_selection.id,
        hub_bulk_action_form: {
          status: new_status,
          assigned_user_id: new_assigned_user_id
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      before { sign_in team_member }

      context "when a new status and assignee are selected" do
        it "changes the status" do
          put :update, params: params

          expect(tax_return_1.reload.state).to eq new_status
          expect(tax_return_2.reload.state).to eq new_status
          expect(tax_return_3.reload.state).to eq new_status

        end

        it "changes the assignee" do
          put :update, params: params

          expect(tax_return_1.reload.assigned_user).to eq site_coordinator
          expect(tax_return_2.reload.assigned_user).to eq site_coordinator
          expect(tax_return_3.reload.assigned_user).to eq site_coordinator
        end

        it "creates the notification and redirects to the notification page" do
          expect {
            put :update, params: params
          }.to change(BulkTaxReturnUpdate, :count).by(1).and(
            change(UserNotification, :count).by(2)
          )

          bulk_update = BulkTaxReturnUpdate.last
          expect(bulk_update.tax_return_selection).to eq tax_return_selection
          expect(bulk_update.user_notification.user).to eq team_member
          expect(bulk_update.user_notification.notifiable.state).to eq new_status
          expect(bulk_update.user_notification.notifiable.updates["status"]).to eq "Ready for call"
          expect(bulk_update.user_notification.notifiable.assigned_user).to eq site_coordinator

          expect(response).to redirect_to hub_user_notifications_path
        end
      end

      context "when 'Keep current status' is selected" do
        let(:params) do
          {
            tax_return_selection_id: tax_return_selection.id,
            hub_bulk_action_form: {
              assigned_user_id: new_assigned_user_id,
              status: BulkTaxReturnUpdate::KEEP
            }
          }
        end

        it "does not change any tax return status" do
          put :update, params: params

          expect(tax_return_1.state).to eq "file_ready_to_file"
          expect(tax_return_2.state).to eq "review_signature_requested"
          expect(tax_return_3.state).to eq "review_signature_requested"
        end

        it "does not create a notification and redirects to the notification page" do
          expect {
            put :update, params: params
          }.to change(BulkTaxReturnUpdate, :count).by(1).and(
            change(UserNotification, :count).by(1)
          )
          expect(response).to redirect_to hub_user_notifications_path
        end
      end

      context "when 'Keep current assignee' is selected" do
        let(:params) do
          {
            tax_return_selection_id: tax_return_selection.id,
            hub_bulk_action_form: {
              assigned_user_id: BulkTaxReturnUpdate::KEEP,
              status: new_status
            }
          }
        end

        it "does not change any tax return assignees" do
          put :update, params: params

          expect(tax_return_1.assigned_user).to eq team_member
          expect(tax_return_2.assigned_user).to eq team_member
          expect(tax_return_3.assigned_user).to eq site_coordinator
        end

        it "does create a notification and redirects to the notification page" do
          expect {
            put :update, params: params
          }.to change(BulkTaxReturnUpdate, :count).by(1).and(
            change(UserNotification, :count).by(2)
          )
          expect(response).to redirect_to hub_user_notifications_path
        end
      end

      context "when 'Remove current assignee' is selected" do
        let(:params) do
          {
            tax_return_selection_id: tax_return_selection.id,
            hub_bulk_action_form: {
              assigned_user_id: BulkTaxReturnUpdate::REMOVE,
              status: new_status
            }
          }
        end

        it "does remove tax return assignees" do
          put :update, params: params

          expect(tax_return_1.reload.assigned_user).to eq nil
          expect(tax_return_2.reload.assigned_user).to eq nil
          expect(tax_return_3.reload.assigned_user).to eq nil
        end

        it "does create a notification and redirects to the notification page" do
          expect {
            put :update, params: params
          }.to change(BulkTaxReturnUpdate, :count).by(1).and(
            change(UserNotification, :count).by(2)
          )

          expect(response).to redirect_to hub_user_notifications_path
        end
      end

      context "when 'Keep current assignee' and 'Keep current status' are selected" do
        let(:params) do
          {
            tax_return_selection_id: tax_return_selection.id,
            hub_bulk_action_form: {
              assigned_user_id: BulkTaxReturnUpdate::KEEP,
              status: BulkTaxReturnUpdate::KEEP
            }
          }
        end

        it "creates an invalid form" do
          put :update, params: params

          expect(assigns(:form).valid?).to eq false
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
                    assigned_user_id: new_assigned_user_id,
                    status: BulkTaxReturnUpdate::KEEP,
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
                team_member,
                en: english_message_body,
                es: spanish_message_body,
                )
          end

          it "creates a Notification for BulkClientMessage" do
            expect do
              put :update, params: params
            end.to change { UserNotification.where(notifiable_type: "BulkClientMessage").count }.by(1)

            bulk_message_notification = UserNotification.where(notifiable_type: "BulkClientMessage").last
            expect(bulk_message_notification.user).to eq(team_member)
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
        let(:note_body) { "An internal note with some text in it" }
        let(:params) do
          {
              tax_return_selection_id: tax_return_selection.id,
              hub_bulk_action_form: {
                  assigned_user_id: new_assigned_user_id,
                  status: BulkTaxReturnUpdate::KEEP,
                  note_body: note_body
              }
          }
        end

        it "saves a note and fires related after creation hooks" do
          expect {
            put :update, params: params
          }.to change(Note, :count).by(1).and(
              change { client.reload.last_internal_or_outgoing_interaction_at }
          ).and(
              change(BulkClientNote, :count).by(1)
          ).and(
              change { UserNotification.where(notifiable_type: "BulkClientNote").count }.by(1)
          )

          expect(client.notes.first.body).to eq note_body
          expect(client.notes.first.user).to eq team_member

          bulk_note = BulkClientNote.last
          expect(bulk_note.tax_return_selection).to eq tax_return_selection
          expect(bulk_note.user_notification.user).to eq team_member
        end
      end
    end
  end
end