require 'rails_helper'

RSpec.describe Hub::BulkActions::ChangeAssigneeAndStatusController do
  let(:client) { create :client, vita_partner: site }
  let(:site) { create :site }
  let(:organization) { create :organization}

  let!(:team_member) { create :user, role: create(:team_member_role, site: site) }
  let!(:site_coordinator) { create :user, role: create(:site_coordinator_role, site: site) }
  let!(:inaccessible_user) { create :user }

  let(:tax_return_1) { create :tax_return, status: "file_ready_to_file", assigned_user: team_member }
  let(:tax_return_2) { create :tax_return, status: "review_signature_requested", assigned_user: team_member }
  let(:tax_return_3) { create :tax_return, status: "review_signature_requested", assigned_user: site_coordinator }
  let(:unselected_tax_return) { create :tax_return, status: "file_efiled", assigned_user: team_member }
  let!(:tax_return_selection) { create :tax_return_selection, tax_returns: [tax_return_1, tax_return_2, tax_return_3] }

  describe "#edit" do
    let(:params) { { tax_return_selection_id: tax_return_selection.id } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in team_member }

      it "tr_statues only includes current statuses of selected tax returns" do
        get :edit, params: params

        expect(assigns(:current_tr_statuses)).to match_array ["file_ready_to_file", "review_signature_requested"]
        expect(assigns(:current_tr_statuses)).not_to include unselected_tax_return.status
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

          expect(tax_return_1.reload.status).to eq new_status
          expect(tax_return_2.reload.status).to eq new_status
          expect(tax_return_3.reload.status).to eq new_status
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
            change(UserNotification, :count).by(1)
          )

          bulk_update = BulkTaxReturnUpdate.last
          expect(bulk_update.tax_return_selection).to eq tax_return_selection
          expect(bulk_update.user_notification.user).to eq team_member
          expect(bulk_update.user_notification.notifiable.status).to eq new_status
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

          expect(tax_return_1.status).to eq "file_ready_to_file"
          expect(tax_return_2.status).to eq "review_signature_requested"
          expect(tax_return_3.status).to eq "review_signature_requested"
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
            change(UserNotification, :count).by(1)
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
            change(UserNotification, :count).by(1)
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
    end
  end
end