require "rails_helper"

RSpec.describe Hub::UpdateCtcClientForm do
  let!(:intake) {
    create :ctc_intake,
           :filled_out,
           :with_ssns,
           :with_contact_info,
           :with_dependents,
           :with_banking_details
  }
  let!(:client) {
    create :client, intake: intake, tax_returns: [tax_return]
  }
  let!(:tax_return) { create :tax_return, filing_status: "married_filing_jointly" }

  describe "#save" do
    let!(:form_attributes) do
      {
          primary_first_name: intake.primary_first_name,
          primary_last_name: intake.primary_last_name,
          preferred_name: intake.preferred_name,
          email_address: intake.email_address,
          phone_number: intake.phone_number,
          sms_phone_number: intake.sms_phone_number,
          primary_birth_date_year: intake.primary_birth_date.year,
          primary_birth_date_month: intake.primary_birth_date.month,
          primary_birth_date_day: intake.primary_birth_date.day,
          street_address: intake.street_address,
          street_address2: intake.street_address2,
          city: intake.city,
          state: intake.state,
          zip_code: intake.zip_code,
          sms_notification_opt_in: sms_opt_in,
          email_notification_opt_in: email_opt_in,
          spouse_first_name: intake.spouse_first_name,
          spouse_last_name: intake.spouse_last_name,
          spouse_email_address: intake.spouse_email_address,
          spouse_ssn: "111227777",
          spouse_tin_type: "itin",
          spouse_birth_date_year: intake.spouse_birth_date.year,
          spouse_birth_date_month: intake.spouse_birth_date.month,
          spouse_birth_date_day: intake.spouse_birth_date.day,
          primary_ssn: "111227778",
          primary_tin_type: "ssn_no_employment",
          preferred_interview_language: intake.preferred_interview_language,
          filing_status: tax_return.filing_status,
          eip1_amount_received: intake.eip1_amount_received,
          eip2_amount_received: intake.eip2_amount_received,
          eip1_and_2_amount_received_confidence: intake.eip1_and_2_amount_received_confidence,
          with_passport_photo_id: "1",
          with_itin_taxpayer_id: "1",
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
        end

        it "persists valid changes to ssn" do
          expect do
            form = described_class.new(client, form_attributes)
            form.save
            intake.reload
          end.to change(intake, :primary_ssn).to("111227777").and change(intake, :primary_tin_type).to("ssn_no_employment")
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

      context "updating the street address" do
        before do
          form_attributes[:street_address2] = "Apt 1"
        end

        it "persists valid changes to street address" do
          expect do
            form = described_class.new(client, form_attributes)
            form.save
            intake.reload
          end.to change(intake, :street_address2).to("Apt 1")
        end
      end
    end
  end

  describe ".existing_attributes" do
    it "creates a form with intake fields including encrypted ones, date of birth, tax return filing info" do
      attributes = described_class.existing_attributes(client.intake, [:id, :primary_ip_pin])
      expect(attributes).to eq({
                                   "id" => intake.id,
                                   "primary_ip_pin" => intake.primary_ip_pin,
                                   "primary_birth_date_day" => 24,
                                   "primary_birth_date_month" => 12,
                                   "primary_birth_date_year" => 1979,
                                   "spouse_birth_date_day" => 23,
                                   "spouse_birth_date_month" => 11,
                                   "spouse_birth_date_year" => 1983,
                                   "filing_status" => "married_filing_jointly",
                                   "filing_status_note" => nil
                               })

    end
  end
end
