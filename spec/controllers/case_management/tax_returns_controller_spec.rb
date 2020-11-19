require "rails_helper"

RSpec.describe CaseManagement::TaxReturnsController, type: :controller do
  let(:vita_partner) { create :vita_partner }
  let(:client) { create :client, vita_partner: vita_partner, intake: create(:intake, preferred_name: "Lucille") }
  let(:tax_return) { create :tax_return, client: client, year: 2018 }

  describe "#edit" do
    let(:params) {
      {
        client_id: client.id,
        id: tax_return.id,
      }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      render_views
      let(:user) { create :user, vita_partner: vita_partner }
      let!(:other_user) { create :user, vita_partner: vita_partner }
      let!(:outside_org_user) { create :user }
      before { sign_in user }

      it "offers me a list of other users in my organization for assignment" do
        get :edit, params: params

        expect(response).to be_ok
        expect(assigns(:assignable_users)).to include(other_user)
        expect(assigns(:assignable_users)).not_to include(outside_org_user)
        assigned_user_dropdown = Nokogiri::HTML.parse(response.body).at_css("select#tax_return_assigned_user_id")

        # does it show a blank option?
        first_option = assigned_user_dropdown.at_css("option:first-child")
        expect(first_option["value"]).to be_blank
        expect(first_option.text).to be_blank

        expect(assigned_user_dropdown.at_css("option[value=\"#{other_user.id}\"]")).to be_present
        expect(assigned_user_dropdown.at_css("option[value=\"#{user.id}\"]")).to be_present

        expect(assigned_user_dropdown.at_css("option[value=\"#{outside_org_user.id}\"]")).not_to be_present
      end
    end

    context "as an admin user" do
      let(:admin) { create :admin_user, vita_partner: create(:vita_partner) }
      let!(:other_user) { create :user, vita_partner: vita_partner }
      let!(:outside_org_user) { create :user, vita_partner: admin.vita_partner }
      before { sign_in admin }

      it "offers a list of users based on client's partner, not admin's org" do
        get :edit, params: params
        expect(assigns(:assignable_users)).to eq([other_user])
      end
    end
  end

  describe "#update" do
    let(:assigned_user) { create :user, name: "Buster" }
    let(:params) {
      {
        client_id: client.id,
        id: tax_return.id,
        tax_return: { assigned_user_id: assigned_user.id }
      }
    }

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update

    context "as an authenticated user" do
      let(:user) { create :user, vita_partner: vita_partner }
      before { sign_in user }

      it "assigns the user to the tax return" do
        put :update, params: params

        tax_return.reload
        expect(tax_return.assigned_user).to eq assigned_user
        expect(response).to redirect_to case_management_clients_path
        expect(flash[:notice]).to eq "Assigned Lucille's 2018 tax return to Buster"
      end

      context "unassigning the tax return" do
        let(:params) {
          {
              client_id: client.id,
              id: tax_return.id,
              tax_return: { assigned_user_id: "" }
          }
        }

        it "removes the assigned user from the tax return" do
          put :update, params: params

          tax_return.reload
          expect(tax_return.assigned_user).not_to be_present
          expect(flash[:notice]).to eq "Assigned Lucille's 2018 tax return to no one"
        end
      end
    end
  end

  describe "#edit_status" do
    let(:user) { create :user_with_org }
    let(:client) { create(:client, vita_partner: user.vita_partner) }
    let!(:intake) { create :intake, client: client }
    let(:tax_return) { create :tax_return, client: client }
    let(:params) { { id: tax_return.id, client_id: tax_return.client } }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit_status

    context "as an authenticated user" do
      before { sign_in user }

      it "returns an ok response" do
        get :edit_status, params: params

        expect(response).to be_ok
      end

      it "finds the tax return" do
        get :edit_status, params: params

        expect(assigns(:tax_return)).to eq(tax_return)
      end

      context "with a tax_return_status param that has a template (from client profile link)" do
        render_views

        before do
          intake.update(locale: "es")
          params.merge!(tax_return: { status: "intake_more_info" } )
          allow_any_instance_of(Intake).to receive(:get_or_create_requested_docs_token).and_return "t0k3n"
        end

        it "prepopulates the form using the locale, status, and relevant template" do
          get :edit_status, params: params

          filled_out_template = <<~MESSAGE_BODY
            ¡Hola!

            Para continuar presentando sus impuestos, necesitamos que nos envíe:
              - Identificación
              - Selfie
              - SSN o ITIN
              - Otro
            Sube tus documentos de forma segura por http://test.host/es/documents/add/t0k3n

            Por favor, háganos saber si usted tiene alguna pregunta. No podemos preparar sus impuestos sin esta información.

            ¡Gracias!
            Su equipo de impuestos en GetYourRefund.org
          MESSAGE_BODY

          expect(assigns(:take_action_form).status).to eq "intake_more_info"
          expect(assigns(:take_action_form).locale).to eq "es"
          expect(assigns(:take_action_form).message_body).to eq filled_out_template
          expect(assigns(:take_action_form).contact_method).to eq "email"
        end

        context "with contact preferences" do
          before { client.intake.update(sms_notification_opt_in: "yes", email_notification_opt_in: "no") }

          it "includes a warning based on contact preferences" do
            get :edit_status, params: params

            expect(assigns(:take_action_form).contact_method).to eq "text_message"
            expect(response.body).to have_text "This client prefers text message instead of email"
          end
        end

        context "with a locale that differs from the client's preferred interview language" do
          before { client.intake.update(preferred_interview_language: "fr") }

          it "includes a warning about the client's language preferences" do
            get :edit_status, params: params

            expect(response.body).to have_text "This client requested French for their interview"
          end
        end
      end
    end
  end

  describe "#update_status" do
    let(:user) { create :user, vita_partner: (create :vita_partner) }
    let(:client) { create :client, vita_partner: user.vita_partner }
    let!(:intake) { create :intake, email_address: "gob@example.com", sms_phone_number: "+14155551212", client: client }
    let(:tax_return) { create :tax_return, status: "intake_in_progress", client: client }
    let(:status) { "review_complete_signature_requested"}
    let(:locale) { "en" }
    let(:internal_note) { "" }
    let(:message_body) { "" }
    let(:contact_method) { "email" }
    let(:params) do
      {
        client_id: tax_return.client,
        id: tax_return.id,
        case_management_take_action_form: {
          status: status,
          internal_note: internal_note,
          locale: locale,
          message_body: message_body,
          contact_method: contact_method,
        }
      }
    end

    it_behaves_like :a_post_action_for_authenticated_users_only, action: :update_status

    context "as an authenticated user" do
      before { sign_in user }

      it "redirects to the messages tab with a basic flash success message" do
        post :update_status, params: params

        expect(response).to redirect_to case_management_client_path(id: tax_return.client)
        expect(flash[:notice]).to eq "Success: Action taken! Updated status."
      end

      context "when a new status is submitted" do
        let(:status) { "intake_needs_assignment" }

        it "creates a system note and updates the status" do
          expect(SystemNote).to receive(:create_status_change_note).with(user, tax_return)

          post :update_status, params: params
          expect(tax_return.reload.status).to eq("intake_needs_assignment")
          expect(flash[:notice]).to match "Updated status"
        end
      end

      context "when the status is the same as he current status" do
        let(:status) { "intake_in_progress" }

        it "does not create a system status change note" do
          expect(SystemNote).not_to receive(:create_status_change_note).with(user, tax_return)

          post :update_status, params: params
        end
      end

      context "there is content in the note field" do
        let(:internal_note) { "Lorem ipsum note about client tax return" }

        it "saves a note" do
          expect do
            post :update_status, params: params
          end.to change(Note, :count).by(1)

          note = Note.last
          expect(note.client).to eq tax_return.client
          expect(note.body).to eq internal_note
          expect(note.user).to eq user

          expect(flash[:notice]).to match "added internal note"
        end
      end

      context "when the note field is blank" do
        let(:internal_note) { " \n" }

        it "does not save a note" do
          expect do
            post :update_status, params: params
          end.not_to change(Note, :count)
        end
      end

      context "when the message body is blank" do
        let(:message_body) { " \n" }
        let(:contact_method) { "email" }

        it "does not send a text message nor email" do
          expect do
            post :update_status, params: params
          end.not_to change(OutgoingEmail, :count)
        end
      end

      context "when the message body is present" do
        let(:message_body) { "There's money in the banana stand" }

        context "and the contact method is email" do
          let(:contact_method) { "email" }
          let(:mock_mailer) { double }
          let(:example_now_time) { DateTime.new(2020, 11, 20) }

          before do
            allow(mock_mailer).to receive(:deliver_later)
            allow(OutgoingEmailMailer).to receive(:user_message).and_return mock_mailer
            allow(ClientChannel).to receive(:broadcast_contact_record)
            allow(DateTime).to receive(:now).and_return example_now_time
          end

          it "sends an email" do
            expect do
              post :update_status, params: params
            end.to change(OutgoingEmail, :count).by 1

            outgoing_email = OutgoingEmail.last
            expect(outgoing_email.to).to eq intake.email_address
            expect(outgoing_email.body).to eq message_body
            expect(outgoing_email.subject).to eq "Update from GetYourRefund"
            expect(outgoing_email.sent_at).to eq example_now_time
            expect(outgoing_email.client).to eq client
            expect(outgoing_email.user).to eq user

            expect(OutgoingEmailMailer).to have_received(:user_message).with(outgoing_email: outgoing_email)
            expect(mock_mailer).to have_received(:deliver_later)
            expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_email)

            expect(flash[:notice]).to match "sent email"
          end
        end

        context "and the contact method is text message" do
          let(:contact_method) { "text_message" }
          let(:example_now_time) { DateTime.new(2020, 11, 20) }

          before do
            allow(SendOutgoingTextMessageJob).to receive(:perform_later)
            allow(ClientChannel).to receive(:broadcast_contact_record)
            allow(DateTime).to receive(:now).and_return example_now_time
          end

          it "sends a text message" do
            expect do
              post :update_status, params: params
            end.to change(OutgoingTextMessage, :count).by 1

            outgoing_text = OutgoingTextMessage.last
            expect(outgoing_text.to_phone_number).to eq intake.sms_phone_number
            expect(outgoing_text.sent_at).to eq example_now_time
            expect(outgoing_text.client).to eq client
            expect(outgoing_text.user).to eq user
            expect(outgoing_text.body).to eq message_body

            expect(SendOutgoingTextMessageJob).to have_received(:perform_later).with(outgoing_text.id)
            expect(ClientChannel).to have_received(:broadcast_contact_record).with(outgoing_text)
            expect(flash[:notice]).to match "sent text message"
          end
        end
      end

      context "when status is changed, message body is present, and internal note is present"do
        let(:status) { "review_in_review" }
        let(:message_body) { "hi" }
        let(:internal_note) { "wyd" }

        it "adds a flash success message listing all the actions taken" do
          post :update_status, params: params

          expect(flash[:notice]).to eq "Success: Action taken! Updated status, sent email, added internal note."
        end
      end
    end
  end
end