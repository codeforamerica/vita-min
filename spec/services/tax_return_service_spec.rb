require "rails_helper"

describe TaxReturnService do
  describe ".handle_status_change" do
    let(:client) { create :client }
    let!(:intake) do
      create(
        :intake,
        client: client,
        locale: "es",
        email_address: "client@example.com",
        spouse_email_address: "spouse@example.com",
        sms_phone_number: "+15005550006"
      )
    end
    let(:user) { create :user }
    let(:tax_return) { create :tax_return, client: client, year: 2019, status: "intake_in_progress" }
    let(:form_params) {
      { tax_return_id: tax_return.id, status: "intake_info_requested" }
    }
    let(:form) { Hub::TakeActionForm.new(client, user, form_params) }

    before do
      allow(ClientMessagingService).to receive(:send_email)
      allow(ClientMessagingService).to receive(:send_email_to_all_signers)
      allow(ClientMessagingService).to receive(:send_text_message)
    end

    it "updates the tax return status" do
      expect {
        TaxReturnService.handle_status_change(form)
      }.to change { tax_return.reload.status }.to("intake_info_requested")
    end

    context "setting TaxReturn.status_last_changed_by" do
      before do
        expect_any_instance_of(TaxReturn).to receive(:status_last_changed_by=).with(user)
      end

      it "sets it to the current_user" do
        TaxReturnService.handle_status_change(form)
      end
    end

    it "record the status change in the action list" do
      action_list = TaxReturnService.handle_status_change(form)

      expect(action_list).to include I18n.t("hub.clients.update_take_action.flash_message.status")
    end

    it "creates a system note to record the status change" do
      expect(SystemNote::StatusChange).to receive(:generate!).with(initiated_by: user, tax_return: tax_return)

      TaxReturnService.handle_status_change(form)
    end

    context "with an invalid status" do
      let(:form_params) { { tax_return_id: tax_return.id, status: "bad-status" } }

      it "raises an error" do
        expect do
          TaxReturnService.handle_status_change(form)
        end.to raise_error(ArgumentError)
      end
    end

    context "when the form has an outgoing message body" do
      let(:form_params) {
        { tax_return_id: tax_return.id, message_body: "message body", contact_method: contact_method, status: "intake_info_requested" }
      }
      context "there is a email contact method" do
        let(:contact_method) { "email" }

        it "sends an email" do
          TaxReturnService.handle_status_change(form)

          expect(ClientMessagingService).to have_received(:send_email).with(client, user, "message body", subject_locale: "es")
        end

        it "records email sending in the action list" do
          action_list = TaxReturnService.handle_status_change(form)

          expect(action_list).to include(I18n.t("hub.clients.update_take_action.flash_message.email"))
        end

        it "does not send a text message" do
          TaxReturnService.handle_status_change(form)

          expect(ClientMessagingService).not_to have_received(:send_text_message)
        end

        context "when the status is signature requested" do
          let(:form_params) {
            { tax_return_id: tax_return.id, message_body: "message body", contact_method: contact_method, status: "review_signature_requested" }
          }

          it "sends an email addressed to all filers" do
            TaxReturnService.handle_status_change(form)

            expect(ClientMessagingService).to have_received(:send_email_to_all_signers).with(client, user, "message body", subject_locale: "es")
          end
        end
      end

      context "there is a text_message contact method" do
        let(:contact_method) { "text_message" }

        it "sends a text message" do
          TaxReturnService.handle_status_change(form)

          expect(ClientMessagingService).to have_received(:send_text_message).with(client, user, "message body")
        end

        it "records text message sending in the action list" do
          action_list = TaxReturnService.handle_status_change(form)

          expect(action_list).to include(I18n.t("hub.clients.update_take_action.flash_message.text_message"))
        end


        it "does not send an email" do
          TaxReturnService.handle_status_change(form)

          expect(ClientMessagingService).not_to have_received(:send_email)
        end
      end
    end

    context "when the form has a blank message body" do
      let(:form_params) {
        { tax_return_id: tax_return.id, message_body: " \n", status: "intake_info_requested" }
      }

      it "does not send an email or a text message" do
        TaxReturnService.handle_status_change(form)

        expect(ClientMessagingService).not_to have_received(:send_email)
        expect(ClientMessagingService).not_to have_received(:send_text_message)
      end
    end

    context "when the form has an internal note body" do
      let(:form_params) {
        { tax_return_id: tax_return.id, internal_note_body: "note body", status: "intake_info_requested" }
      }

      it "creates an internal note from the user" do
        expect do
          TaxReturnService.handle_status_change(form)
        end.to change(Note, :count).by 1

        note = Note.last
        expect(note.client).to eq client
        expect(note.user).to eq user
        expect(note.body).to eq "note body"
      end

      it "records the note making in the action list" do
        action_list = TaxReturnService.handle_status_change(form)

        expect(action_list).to include(I18n.t("hub.clients.update_take_action.flash_message.internal_note"))
      end
    end

    context "when the form has a blank internal note body" do
      let(:form_params) {
        { tax_return_id: tax_return.id, internal_note_body: " \n", status: "intake_info_requested" }
      }

      it "does not create an internal note" do
        expect do
          TaxReturnService.handle_status_change(form)
        end.not_to change(Note, :count)
      end
    end
  end
end
