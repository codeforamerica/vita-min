require "rails_helper"

RSpec.describe Hub::CtcClientsController do
  let!(:organization) { create :organization, allows_greeters: false, processes_ctc: true }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization), timezone: "America/Los_Angeles") }

  describe "#edit" do
    let(:client) { create :client, :with_return, intake: (create :ctc_intake) }
    let(:params) {
      { id: client.id }
    }

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :edit

    context "as an authenticated user" do
      before { sign_in user }

      it "renders edit for the client" do
        get :edit, params: params

        expect(response).to be_ok
        expect(assigns(:form)).to be_an_instance_of Hub::UpdateCtcClientForm
      end
    end
  end

  describe "#update" do
    let!(:client) { create :client, :with_return, intake: intake }

    let!(:intake) { create :ctc_intake, :filled_out_ctc, :with_contact_info, :with_ssns, :with_dependents, email_address: "cher@example.com", primary_last_name: "Cherimoya" }
    let(:first_dependent) { intake.dependents.first }
    let!(:params) do
      {
        id: client.id,
        hub_update_ctc_client_form: {
          primary_first_name: 'San',
          primary_last_name: 'Mateo',
          preferred_name: intake.preferred_name,
          email_address: 'san@mateo.com',
          phone_number: intake.phone_number,
          sms_phone_number: intake.sms_phone_number,
          primary_birth_date_year: intake.primary_birth_date.year,
          primary_birth_date_month: intake.primary_birth_date.month,
          primary_birth_date_day: intake.primary_birth_date.day,
          street_address: intake.street_address,
          city: intake.city,
          state: intake.state,
          zip_code: intake.zip_code,
          sms_notification_opt_in: 'yes',
          email_notification_opt_in: 'yes',
          spouse_first_name: 'San',
          spouse_last_name: 'Diego',
          spouse_email_address: 'san@diego.com',
          spouse_ssn: '123456789',
          spouse_ssn_confirmation: '123456789',
          spouse_birth_date_year: 1980,
          spouse_birth_date_month: 1,
          spouse_birth_date_day: 11,
          primary_ssn: "111227778",
          primary_ssn_confirmation: "111227778",
          filing_status: client.tax_returns.last.filing_status,
          eip1_amount_received: '9000',
          eip2_amount_received: intake.eip2_amount_received,
          eip1_and_2_amount_received_confidence: intake.eip1_and_2_amount_received_confidence,
          refund_payment_method: "check",
          with_passport_photo_id: "1",
          with_itin_taxpayer_id: "1",
          use_primary_name_for_name_control: false,
          primary_ip_pin: intake.primary_ip_pin,
          spouse_ip_pin: intake.spouse_ip_pin,
          has_crypto_income: "false",
          dependents_attributes: {
            "0" => { id: first_dependent.id, first_name: "Updated Dependent", last_name: "Name", birth_date_year: "2001", birth_date_month: "10", birth_date_day: "9", relationship: first_dependent.relationship, ssn: "111227777" },
          }
        }
      }
    end

    it_behaves_like :a_get_action_for_authenticated_users_only, action: :update

    context "with a signed in user" do
      let(:user) { create(:user, role: create(:organization_lead_role, organization: organization)) }

      before do
        sign_in user
      end

      it "updates the clients intake and creates a system note" do
        post :update, params: params
        client.reload
        intake.reload
        expect(intake.primary_first_name).to eq "San"
        expect(client.legal_name).to eq "San Mateo"
        expect(client.intake.email_address).to eq "san@mateo.com"
        expect(client.intake.eip1_amount_received).to eq 9000
        expect(client.intake.spouse_last_name).to eq "Diego"
        expect(client.intake.spouse_email_address).to eq "san@diego.com"
        expect(client.intake.spouse_ssn).to eq "123456789"
        expect(client.intake.spouse_birth_date).to eq Date.new(1980, 1, 11)
        expect(first_dependent.reload.first_name).to eq "Updated Dependent"
        expect(client.intake.dependents.count).to eq 1
        expect(response).to redirect_to hub_client_path(id: client.id)

        system_note = SystemNote::ClientChange.last
        expect(system_note.client).to eq(client)
        expect(system_note.user).to eq(user)
        expect(system_note.data['changes']).to match({
          "spouse_ssn" => ["[REDACTED]", "[REDACTED]"],
          "primary_ssn" => ["[REDACTED]", "[REDACTED]"],
          "email_address" => ["cher@example.com", "san@mateo.com"],
          "primary_tin_type" => ["ssn", nil],
          "spouse_last_name" => ["Hesse", "Diego"],
          "primary_last_name" => ["Cherimoya", "Mateo"],
          "spouse_birth_date" => ["1929-09-02", "1980-01-11"],
          "spouse_first_name" => ["Eva", "San"],
          "primary_first_name" => ["Cher", "San"],
          "eip1_amount_received" => [1000, 9000],
          "spouse_email_address" => ["eva@hesse.com", "san@diego.com"],
          "spouse_last_four_ssn" => ["[REDACTED]", "[REDACTED]"],
          "primary_last_four_ssn" => ["[REDACTED]", "[REDACTED]"],
          "preferred_interview_language" => ["en", nil],
        })
      end

      context "when the client's email address has changed" do
        before do
          params[:hub_update_ctc_client_form][:email_address] = 'changed@example.com'
        end

        it "sends a message to the new and old email addresses" do
          expect do
            post :update, params: params
          end.to change(OutgoingEmail, :count).by(2)

          expect(OutgoingEmail.all.map(&:to)).to match_array(['cher@example.com', 'changed@example.com'])
        end

        context "if the intake was drop off" do
          before do
            client.tax_returns.last.update(service_type: :drop_off)
          end

          it "sends no notifications" do
            expect do
              post :update, params: params
            end.not_to change(OutgoingEmail, :count)
          end
        end
      end

      context "when the client's phone number has changed" do
        before do
          params[:hub_update_ctc_client_form][:sms_phone_number] = '4155551234'
        end

        it "sends a message to the new and old phone numbers" do
          expect do
            post :update, params: params
          end.to change(OutgoingTextMessage, :count).by(2)

          expect(OutgoingTextMessage.all.map(&:to)).to match_array(['(415) 555-1212', '(415) 555-1234'])
        end

        context "if the intake was drop off" do
          before do
            client.tax_returns.last.update(service_type: :drop_off)
          end

          it "sends no notifications" do
            expect do
              post :update, params: params
            end.not_to change(OutgoingTextMessage, :count)
          end
        end
      end

      context "with invalid params" do
        let(:params) {
          {
            id: client.id,
            hub_update_ctc_client_form: {
              primary_first_name: "",
            }
          }
        }

        it "renders edit" do
          post :update, params: params

          expect(response).to render_template :edit
        end
      end

      context "with invalid dependent params" do
        let(:params) {
          {
            id: client.id,
            hub_update_ctc_client_form: {
              dependents_attributes: { 0 => { "first_name": "", last_name: "", birth_date_month: "", birth_date_year: "", birth_date_day: "" } },
            }
          }
        }

        it "renders edit" do
          post :update, params: params

          expect(response).to render_template :edit
        end

        it "displays a flash message" do
          post :update, params: params
          expect(flash[:alert]).to eq "Please fix indicated errors before continuing."
        end
      end
    end
  end
end
