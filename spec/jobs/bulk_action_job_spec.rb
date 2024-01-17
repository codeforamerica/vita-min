require "rails_helper"

describe BulkActionJob do
  describe '#perform' do
    let(:organization) { create :organization }
    let(:user) { create :organization_lead_user, organization: organization }
    let(:english_message_body) { "I moved your case to a new org!" }
    let(:spanish_message_body) { "¡Mové su caso a una organización nueva!" }
    let(:email_address) { "client@example.com" }
    let(:params) { { message_body_en: english_message_body, message_body_es: spanish_message_body } }
    let(:tax_return_selection) { create :tax_return_selection }

    context "when sending a message" do
      let(:task_type) { :any_task_type }
      let(:email) { "email@example.com" }
      let(:sms_phone_number) { "+14155551212" }

      context "with a client needing an email & text" do
        let!(:selected_client) { create :client, intake: intake, tax_returns: [(build :gyr_tax_return, tax_return_selections: [tax_return_selection])], vita_partner: organization }
        let(:intake) { build :intake, email_address: email, email_notification_opt_in: "yes", sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes", locale: locale }
        let(:locale) { "en" }

        before do
          allow(ClientMessagingService).to receive(:send_email).and_call_original
          allow(ClientMessagingService).to receive(:send_text_message).and_call_original
        end

        it "sends an email & text" do
          described_class.perform_now(
            task: task_type,
            user: user,
            tax_return_selection: tax_return_selection,
            form_params: params
          )

          expect(ClientMessagingService).to have_received(:send_email).with(
            body: english_message_body,
            client: selected_client,
            user: user,
            subject: nil
          )
          expect(ClientMessagingService).to have_received(:send_text_message).with(
            body: english_message_body,
            client: selected_client,
            user: user
          )
        end

        context "when the bulk message is configured to only send on a single medium" do
          it "can send only email" do
            described_class.perform_now(
              task: task_type,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params.merge(send_only: 'email')
            )

            expect(ClientMessagingService).to have_received(:send_email).with(
              body: english_message_body,
              client: selected_client,
              user: user,
              subject: nil
            )
            expect(ClientMessagingService).not_to have_received(:send_text_message)
          end

          it "can send only text messages" do
            described_class.perform_now(
              task: task_type,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params.merge(send_only: 'text_message')
            )

            expect(ClientMessagingService).not_to have_received(:send_email)
            expect(ClientMessagingService).to have_received(:send_text_message).with(
              body: english_message_body,
              client: selected_client,
              user: user
            )
          end
        end

        it "creates a Notification for BulkClientMessage" do
          expect do
            described_class.perform_now(
              task: :any_task,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params
            )
          end.to change(UserNotification, :count).by(1)

          bulk_message_notification = UserNotification.last
          expect(bulk_message_notification.notifiable_type).to eq("BulkClientMessage")
          expect(bulk_message_notification.user).to eq(user)
          bulk_client_message = bulk_message_notification.notifiable
          expect(bulk_client_message.outgoing_emails.count).to eq(1)
          expect(bulk_client_message.outgoing_text_messages.count).to eq(1)
        end

        context "when the intake locale is nil" do
          let(:locale) { nil }

          it "sends the message in English" do
            described_class.perform_now(
              task: task_type,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params
            )

            expect(ClientMessagingService).to have_received(:send_email).with(
              body: english_message_body,
              client: selected_client,
              user: user,
              subject: nil
            )
            expect(ClientMessagingService).to have_received(:send_text_message).with(
              body: english_message_body,
              client: selected_client,
              user: user
            )
          end
        end

        context "with a client in Spanish" do
          let(:locale) { "es" }

          it "sends an email & text" do
            described_class.perform_now(
              task: task_type,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params
            )

            expect(ClientMessagingService).to have_received(:send_email).with(
              body: spanish_message_body,
              client: selected_client,
              user: user,
              subject: nil
            )
            expect(ClientMessagingService).to have_received(:send_text_message).with(
              body: spanish_message_body,
              client: selected_client,
              user: user
            )
          end
        end

        context "with an archived client" do
          let(:intake) { nil }
          let(:locale) { "es" }
          let!(:archived_2021_intake) { create :archived_2021_gyr_intake, email_address: email, email_notification_opt_in: "yes", sms_phone_number: sms_phone_number, sms_notification_opt_in: "yes", locale: locale, client: selected_client }

          it "sends an email & text" do
            described_class.perform_now(
              task: task_type,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params
            )

            expect(ClientMessagingService).to have_received(:send_email).with(
              body: spanish_message_body,
              client: selected_client,
              user: user,
              subject: nil
            )
            expect(ClientMessagingService).to have_received(:send_text_message).with(
              body: spanish_message_body,
              client: selected_client,
              user: user
            )
          end
        end

        context "when the message for a locale is missing" do
          let(:params) { { message_body_en: english_message_body } }
          let(:locale) { "es" }

          it "raises an error" do
            expect do
              described_class.perform_now(
                task: task_type,
                user: user,
                tax_return_selection: tax_return_selection,
                form_params: params
              )
            end.to raise_error(ArgumentError)
          end
        end

        context "when the client is not accessible to this user" do
          let(:user) { create(:organization_lead_user) }

          it "sends no messages" do
            described_class.perform_now(
              task: task_type,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params
            )

            expect(ClientMessagingService).not_to have_received(:send_email)
            expect(ClientMessagingService).not_to have_received(:send_text_message)
          end
        end
      end
    end

    context "when creating a note" do
      let!(:selected_client_1) { create :client, intake: (build :intake), vita_partner: organization, tax_returns: [(build :gyr_tax_return, tax_return_selections: [tax_return_selection])] }
      let!(:selected_client_2) { create :client, intake: (build :intake), vita_partner: organization, tax_returns: [(build :gyr_tax_return, tax_return_selections: [tax_return_selection])] }
      let(:note_body) { "An internal note with some text in it" }
      let(:params) do
        { note_body: note_body }
      end

      it "saves a note and fires related after creation hooks" do
        expect {
          described_class.perform_now(
            task: :any_task,
            user: user,
            tax_return_selection: tax_return_selection,
            form_params: params
          )
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

    context "when changing organization" do
      let!(:selected_client) { create :client, intake: (build :intake), tax_returns: [(build :gyr_tax_return, tax_return_selections: [tax_return_selection])], vita_partner: organization }
      let(:new_vita_partner) { create :site, parent_organization: organization }
      let(:params) do
        { vita_partner_id: new_vita_partner.id.to_s }
      end

      it "updates the organization on all selected clients, creates the right record, and redirects to the notification page" do
        expect {
          described_class.perform_now(
            task: :change_organization,
            user: user,
            tax_return_selection: tax_return_selection,
            form_params: params
          )
        }.to change { selected_client.reload.vita_partner }.from(organization).to(new_vita_partner).and(
          change(BulkClientOrganizationUpdate, :count).by(1)
        ).and(
          change(UserNotification, :count).by(1)
        )

        expect(user.notifications.map(&:notifiable_type)).to match_array(["BulkClientOrganizationUpdate"])
        bulk_update = BulkClientOrganizationUpdate.last
        expect(bulk_update.tax_return_selection).to eq tax_return_selection
        expect(bulk_update.user_notification.user).to eq user
        expect(bulk_update.user_notification.notifiable.vita_partner).to eq new_vita_partner
      end

      context "when user only has access to update some clients" do
        let!(:inaccessible_selected_client) { create :client, intake: (build :intake), tax_returns: [(build :gyr_tax_return, tax_return_selections: [tax_return_selection])], vita_partner: build(:organization) }

        before do
          # prove we did the setup good
          expect(tax_return_selection.clients).to include(inaccessible_selected_client)
        end

        it "only updates the clients that the user can access" do
          expect {
            described_class.perform_now(
              task: :change_organization,
              user: user,
              tax_return_selection: tax_return_selection,
              form_params: params
            )
          }.not_to change { inaccessible_selected_client.reload.vita_partner }
        end
      end

      context "when users are assigned to the returns and don't have access through the new partner" do
        let(:old_site) { create :site, parent_organization: organization }
        let(:assigned_user_at_old_site) { create :site_coordinator_user, sites: [old_site] }
        let(:assigned_user_who_retains_access) { create :organization_lead_user, organization: organization }
        let(:selected_client) { create :client, intake: (build :intake), vita_partner: old_site }
        let!(:still_assigned_return) { create :tax_return, client: selected_client, assigned_user: assigned_user_who_retains_access, year: 2018, tax_return_selections: [tax_return_selection] }
        let!(:unassigned_return) { create :tax_return, client: selected_client, assigned_user: assigned_user_at_old_site, year: 2017, tax_return_selections: [tax_return_selection] }
        let!(:not_selected_return) { create :tax_return, client: selected_client, assigned_user: assigned_user_at_old_site, year: 2019 }

        it "unassigns all users who are losing access" do
          described_class.perform_now(
            task: :change_organization,
            user: user,
            tax_return_selection: tax_return_selection,
            form_params: params
          )

          expect(selected_client.reload.vita_partner).to eq new_vita_partner
          expect(assigned_user_at_old_site.reload.assigned_tax_returns).to be_empty
          expect(unassigned_return.reload.assigned_user).to eq nil
          expect(assigned_user_who_retains_access.reload.assigned_tax_returns).to eq [still_assigned_return]
        end
      end
    end

    context "when changing the assignee or status" do
      let(:tax_return_1) { create :gyr_tax_return, :file_ready_to_file, assigned_user: team_member, client: client }
      let(:tax_return_2) { create :tax_return, :review_signature_requested, assigned_user: team_member, client: client, year: 2019 }
      let(:tax_return_3) { create :tax_return, :review_signature_requested, assigned_user: site_coordinator, client: client, year: 2018 }
      let(:unselected_tax_return) { create :gyr_tax_return, :file_efiled, assigned_user: team_member }
      let!(:tax_return_selection) { create :tax_return_selection, tax_returns: [tax_return_1, tax_return_2, tax_return_3] }

      let(:new_status) { "review_ready_for_call" }
      let(:new_assigned_user_id) { site_coordinator.id }

      let(:client) { create :client, vita_partner: site, intake: build(:intake) }
      let(:site) { create :site }

      let!(:team_member) { create :user, role: create(:team_member_role, sites: [site]) }
      let!(:site_coordinator) { create :user, role: create(:site_coordinator_role, sites: [site]) }
      let!(:inaccessible_user) { create :user }

      let(:params) do
        {
          status: new_status,
          assigned_user_id: new_assigned_user_id.to_s
        }
      end

      it "changes the status" do
        described_class.perform_now(
          task: :change_assignee_and_status,
          user: team_member,
          tax_return_selection: tax_return_selection,
          form_params: params
        )

        expect(tax_return_1.reload.current_state).to eq new_status
        expect(tax_return_2.reload.current_state).to eq new_status
        expect(tax_return_3.reload.current_state).to eq new_status
      end

      it "changes the assignee" do
        described_class.perform_now(
          task: :change_assignee_and_status,
          user: team_member,
          tax_return_selection: tax_return_selection,
          form_params: params
        )

        expect(tax_return_1.reload.assigned_user).to eq site_coordinator
        expect(tax_return_2.reload.assigned_user).to eq site_coordinator
        expect(tax_return_3.reload.assigned_user).to eq site_coordinator
      end

      it "creates the notification" do
        expect {
          described_class.perform_now(
            task: :change_assignee_and_status,
            user: team_member,
            tax_return_selection: tax_return_selection,
            form_params: params
          )
        }.to change(BulkTaxReturnUpdate, :count).by(1).and(
          change(UserNotification, :count).by(2)
        )

        expect(team_member.notifications.map(&:notifiable_type)).to match_array(["BulkTaxReturnUpdate", "BulkClientMessage"]) # this status has a corresponding default message
        bulk_update = BulkTaxReturnUpdate.last
        expect(bulk_update.tax_return_selection).to eq tax_return_selection
        expect(bulk_update.user_notification.user).to eq team_member
        expect(bulk_update.user_notification.notifiable.state).to eq new_status
        expect(bulk_update.user_notification.notifiable.updates["status"]).to eq "Ready for call"
        expect(bulk_update.user_notification.notifiable.assigned_user).to eq site_coordinator
      end

      it "creates the system note" do
        described_class.perform_now(
          task: :change_assignee_and_status,
          user: team_member,
          tax_return_selection: tax_return_selection,
          form_params: params
        )

        expect(client.reload.system_notes.map(&:body)).to include "#{team_member.name_with_role} updated 2023 tax return status from Final steps/Ready to file to Quality review/Ready for call"
      end

      context "when 'Keep current status' is selected" do
        let(:params) do
          {
            assigned_user_id: new_assigned_user_id,
            status: BulkTaxReturnUpdate::KEEP
          }
        end

        it "does not change any tax return status or add a system note" do
          described_class.perform_now(
            task: :change_assignee_and_status,
            user: team_member,
            tax_return_selection: tax_return_selection,
            form_params: params
          )

          expect(tax_return_1.current_state).to eq "file_ready_to_file"
          expect(tax_return_2.current_state).to eq "review_signature_requested"
          expect(tax_return_3.current_state).to eq "review_signature_requested"
          expect(client.reload.system_notes.where(type: "SystemNote::StatusChange")).to be_empty
        end

        it "creates a notification" do
          expect {
            described_class.perform_now(
              task: :change_assignee_and_status,
              user: team_member,
              tax_return_selection: tax_return_selection,
              form_params: params
            )
          }.to change(BulkTaxReturnUpdate, :count).by(1).and(
            change(UserNotification, :count).by(1)
          )
        end
      end

      context "when 'Keep current assignee' is selected" do
        let(:params) do
          {
            assigned_user_id: BulkTaxReturnUpdate::KEEP,
            status: new_status
          }
        end

        it "does not change any tax return assignees" do
          described_class.perform_now(
            task: :change_assignee_and_status,
            user: team_member,
            tax_return_selection: tax_return_selection,
            form_params: params
          )

          expect(tax_return_1.assigned_user).to eq team_member
          expect(tax_return_2.assigned_user).to eq team_member
          expect(tax_return_3.assigned_user).to eq site_coordinator
        end

        it "does create notifications" do
          expect {
            described_class.perform_now(
              task: :change_assignee_and_status,
              user: team_member,
              tax_return_selection: tax_return_selection,
              form_params: params
            )
          }.to change(BulkTaxReturnUpdate, :count).by(1).and(
            change(UserNotification, :count).by(2)
          )
        end
      end

      context "when 'Remove current assignee' is selected" do
        let(:params) do
          {
            assigned_user_id: BulkTaxReturnUpdate::REMOVE,
            status: new_status
          }
        end

        it "does remove tax return assignees" do
          described_class.perform_now(
            task: :change_assignee_and_status,
            user: team_member,
            tax_return_selection: tax_return_selection,
            form_params: params
          )

          expect(tax_return_1.reload.assigned_user).to eq nil
          expect(tax_return_2.reload.assigned_user).to eq nil
          expect(tax_return_3.reload.assigned_user).to eq nil
        end

        it "does create notifications" do
          expect {
            described_class.perform_now(
              task: :change_assignee_and_status,
              user: team_member,
              tax_return_selection: tax_return_selection,
              form_params: params
            )
          }.to change(BulkTaxReturnUpdate, :count).by(1).and(
            change(UserNotification, :count).by(2)
          )
        end
      end
    end
  end
end
