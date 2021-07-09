require "rails_helper"

RSpec.describe Hub::UpdateCtcClientForm do
  describe "#save" do
    let!(:intake) {
      create :ctc_intake,
             :filled_out,
             :with_contact_info,
             :with_dependents,
             :with_banking_details
    }
    let!(:client) {
      create :client, intake: intake, tax_returns: [tax_return]
    }
    let!(:tax_return) { create :tax_return, filing_status: "married_filing_jointly" }
    let!(:form_attributes) do
      {
        primary_first_name: intake.primary_first_name,
        primary_last_name: intake.primary_last_name,
        preferred_name: intake.preferred_name,
        email_address: intake.email_address,
        phone_number: intake.phone_number,
        sms_phone_number: intake.sms_phone_number,
        preferred_interview_language: intake.preferred_interview_language,
        primary_birth_date_year: intake.primary_birth_date.year,
        primary_birth_date_month: intake.primary_birth_date.month,
        primary_birth_date_day: intake.primary_birth_date.day,
        street_address: intake.street_address,
        city: intake.city,
        state: intake.state,
        zip_code: intake.zip_code,
        sms_notification_opt_in: sms_opt_in,
        email_notification_opt_in: email_opt_in,
        spouse_first_name: intake.spouse_first_name,
        spouse_last_name: intake.spouse_last_name,
        spouse_email_address: intake.spouse_email_address,
        spouse_ssn: intake.spouse_ssn,
        spouse_ssn_confirmation: intake.spouse_ssn,
        spouse_birth_date_year: intake.spouse_birth_date.year,
        spouse_birth_date_month: intake.spouse_birth_date.month,
        spouse_birth_date_day: intake.spouse_birth_date.day,
        state_of_residence: intake.state_of_residence,
        primary_ssn: intake.primary_ssn,
        primary_ssn_confirmation: intake.primary_ssn,
        filing_status: tax_return.filing_status,
        recovery_rebate_credit_amount_1: intake.recovery_rebate_credit_amount_1,
        recovery_rebate_credit_amount_2: intake.recovery_rebate_credit_amount_2,
        recovery_rebate_credit_amount_confidence: intake.recovery_rebate_credit_amount_confidence,
        refund_payment_method: intake.refund_payment_method,
        navigator_name: intake.navigator_name,
        navigator_has_verified_client_identity: intake.navigator_has_verified_client_identity,
        with_passport_photo_id: intake.with_passport_photo_id,
        with_itin_taxpayer_id: intake.with_itin_taxpayer_id,
        primary_ip_pin: intake.primary_ip_pin,
        spouse_ip_pin: intake.spouse_ip_pin,
      }
    end

    let(:sms_opt_in) { "yes" }
    let(:email_opt_in) { "no" }

    context "updating a client" do
      context "updating the ssn" do
        before do
          form_attributes[:primary_ssn] = "111-22-7777"
          form_attributes[:primary_ssn_confirmation] = "111-22-7777"
        end

        it "persists valid changes to ssn" do
          expect do
            form = described_class.new(client, form_attributes)
            form.save
            intake.reload
          end.to change(intake, :primary_ssn).to "111-22-7777"
        end
      end

      context "updating the filing_status" do
        before do
          form_attributes[:filing_status] = "single"
        end

        it "persists valid changes to filing_status" do
          expect do
            form = described_class.new(client, form_attributes)
            form.save
            tax_return.reload
          end.to change(tax_return, :filing_status).to "single"
        end
      end
    end
  end
end
