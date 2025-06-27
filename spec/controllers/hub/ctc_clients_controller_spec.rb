require "rails_helper"

RSpec.describe Hub::CtcClientsController do
  let!(:organization) { create :organization, allows_greeters: false, processes_ctc: true }
  let(:user) { create(:user, role: create(:organization_lead_role, organization: organization), timezone: "America/Los_Angeles") }

  describe "#edit" do
    let(:client) { create :client, :with_ctc_return, intake: (build :ctc_intake, product_year: Rails.configuration.product_year), vita_partner: organization }
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

      context "with an archived intake" do
        let(:client) { create :client, :with_ctc_return, intake: (build :ctc_intake), vita_partner: organization }

        it "response is forbidden (403)" do
          get :edit, params: params
          expect(response).to be_forbidden
        end
      end
    end
  end

  describe "#update" do
    let!(:client) { create :client, :with_ctc_return, intake: intake, vita_partner: organization }

    let(:intake) { build :ctc_intake, :filled_out_ctc, :with_contact_info, :with_ssns, :with_dependents, email_address: "cher@example.com", primary_last_name: "Cherimoya", product_year: Rails.configuration.product_year }
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
          primary_birth_date_year: intake.primary.birth_date.year,
          primary_birth_date_month: intake.primary.birth_date.month,
          primary_birth_date_day: intake.primary.birth_date.day,
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
          spouse_was_blind: 'no',
          was_blind: 'no',
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
  end
end
