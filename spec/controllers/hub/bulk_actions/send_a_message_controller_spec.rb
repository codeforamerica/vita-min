require 'rails_helper'

RSpec.describe Hub::BulkActions::SendAMessageController do
  let(:organization) { create :organization }
  let(:tax_return_selection) { create :tax_return_selection }
  let(:user) { create :organization_lead_user, organization: organization }

  describe "#update" do
    let(:new_vita_partner) { create :site, parent_organization: organization }
    let(:params) do
      {
        tax_return_selection_id: tax_return_selection.id,
        hub_bulk_action_form: {
          note_body: "this is my note"
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      before { sign_in user }

      context "with valid message params" do
        let(:english_message_body) { "I moved your case to a new org!" }
        let(:spanish_message_body) { "¡Mové su caso a una organización nueva!" }
        let(:params) do
          {
            tax_return_selection_id: tax_return_selection.id,
            hub_bulk_action_form: {
              message_body_en: english_message_body,
              message_body_es: spanish_message_body
            }
          }
        end

        before do
          allow_any_instance_of(Hub::BulkActionForm).to receive(:valid?).and_return true
        end

        it "creates a notification and enqueues a job to do the rest" do
          expect do
            put :update, params: params
          end.to change { user.notifications.count }.by(1).and(
            have_enqueued_job(BulkActionJob).with(
              task: :send_a_message,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params[:hub_bulk_action_form]
            )
          )
        end
      end

      context "with invalid message params" do
        before do
          allow_any_instance_of(Hub::BulkActionForm).to receive(:valid?).and_return false
        end

        it "does not enqueue a job" do
          expect {
            expect {
              put :update, params: params
            }.not_to change { user.notifications.count }
          }.not_to have_enqueued_job
        end
      end
    end
  end
end
