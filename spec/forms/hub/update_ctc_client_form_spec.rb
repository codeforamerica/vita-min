require "rails_helper"

RSpec.describe Hub::UpdateCtcClientForm, requires_default_vita_partners: true do
  let!(:intake) {
    create :ctc_intake,
           :filled_out_ctc,
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
          spouse_ssn: spouse_ssn,
          spouse_tin_type: spouse_tin_type,
          spouse_birth_date_year: intake.spouse_birth_date.year,
          spouse_birth_date_month: intake.spouse_birth_date.month,
          spouse_birth_date_day: intake.spouse_birth_date.day,
          primary_ssn: primary_ssn,
          primary_tin_type: primary_tin_type,
          preferred_interview_language: intake.preferred_interview_language,
          filing_status: tax_return.filing_status,
          eip1_amount_received: intake.eip1_amount_received,
          eip2_amount_received: intake.eip2_amount_received,
          eip1_and_2_amount_received_confidence: intake.eip1_and_2_amount_received_confidence,
          with_passport_photo_id: "1",
          with_itin_taxpayer_id: "1",
          primary_ip_pin: intake.primary_ip_pin,
          spouse_ip_pin: intake.spouse_ip_pin,
          dependents_attributes: {
            "0" => {
              id: intake.dependents.first.id,
              first_name: intake.dependents.first.first_name,
              last_name: intake.dependents.first.last_name,
              relationship: dependent_relationship,
              ssn: dependent_ssn,
              tin_type: 'ssn',
              birth_date_month: "May",
              birth_date_day: "9",
              birth_date_year: "2013",
            }
          }
      }
    end
    let(:primary_ssn) { "111-22-4333" }
    let(:primary_tin_type) { "ssn_no_employment" }

    let(:spouse_ssn) { "999-78-1224" }
    let(:spouse_tin_type) { "itin" }

    let(:dependent_ssn) { '111-33-3333' }
    let(:dependent_relationship) { 'daughter' }

    let(:sms_opt_in) { "yes" }
    let(:email_opt_in) { "no" }

    context "updating a client" do
      context "updating the primary ssn" do
        it "persists valid changes to ssn" do
          expect do
            form = described_class.new(client, form_attributes)
            form.save
            intake.reload
          end.to change(intake, :primary_ssn).to("111224333").and change(intake, :primary_tin_type).to("ssn_no_employment")
        end

        context "when it is an invalid ssn" do
          let(:primary_ssn) { "000-00-0000" }

          it "validates the data correctly" do
            form = described_class.new(client, form_attributes)
            form.save
            expect(form.errors).to include(:primary_ssn)
          end
        end

        context "when it is an itin" do
          let(:primary_ssn) { "999-78-1223" }
          let(:primary_tin_type) { "itin" }

          it "persists valid changes to ssn" do
            expect do
              form = described_class.new(client, form_attributes)
              form.save
              intake.reload
            end.to change(intake, :primary_ssn).to("999781223").and change(intake, :primary_tin_type).to("itin")
          end

          context "when it is an invalid itin" do
            let(:primary_ssn) { "111-22-4333" }

            it "validates the data correctly" do
              form = described_class.new(client, form_attributes)
              form.save
              expect(form.errors).to include(:primary_ssn)
            end
          end
        end
      end

      context "updating the spouse ssn" do
        it "persists valid changes to ssn" do
          expect do
            form = described_class.new(client, form_attributes)
            form.save
            intake.reload
          end.to change(intake, :spouse_ssn).to("999781224").and change(intake, :spouse_tin_type).to("itin")
        end

        context "when it is an invalid itin" do
          let(:spouse_ssn) { "000-00-0000" }

          it "validates the data correctly" do
            form = described_class.new(client, form_attributes)
            form.save
            expect(form.errors).to include(:spouse_ssn)
          end
        end

        context "when it is an invalid ssn" do
          let(:spouse_ssn) { "" }
          let(:spouse_tin_type) { "ssn" }

          it "validates the data correctly" do
            form = described_class.new(client, form_attributes)
            form.save
            expect(form.errors).to include(:spouse_ssn)
          end
        end
      end

      context "updating dependents" do
        context 'when relationship is missing' do
          let(:dependent_relationship) { nil }

          it "shows a validation error" do
            form = described_class.new(client, form_attributes)
            form.save
            expect(form.dependents.first.errors).to include(:relationship)
          end
        end

        context 'when SSN is missing' do
          let(:dependent_ssn) { nil }

          it "shows a validation error" do
            form = described_class.new(client, form_attributes)
            form.save
            expect(form.dependents.first.errors).to include(:ssn)
          end
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

      context "updating prior year tax information" do
        before do
          form_attributes[:primary_prior_year_agi_amount] = "$1,213"
          form_attributes[:spouse_prior_year_agi_amount] = "$1,216"

          form_attributes[:primary_prior_year_signature_pin] = "12345"
          form_attributes[:spouse_prior_year_signature_pin] = "54321"
        end

        it "persists changes to the agi and signature pin fields" do
          expect do
            form = described_class.new(client, form_attributes)
            form.save
            intake.reload
          end.to change(intake, :primary_prior_year_agi_amount).to(1213)
            .and change(intake, :spouse_prior_year_agi_amount).to(1216)
            .and change(intake, :primary_prior_year_signature_pin).to("12345")
            .and change(intake, :spouse_prior_year_signature_pin).to("54321")
        end

      end

      context "updating the eip amounts received" do
        context "if the eip1/2 values were already set" do
          before do
            intake.update(eip1_amount_received: 123, eip2_amount_received: 456)

            form_attributes[:eip1_amount_received] = ""
            form_attributes[:eip2_amount_received] = ""
          end

          it "does not allow settings amounts to nil" do
            expect do
              form = described_class.new(client, form_attributes)
              form.save
              intake.reload
            end.not_to change(intake, :eip1_amount_received)
            expect(intake.eip2_amount_received).to eq(456)
          end
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
                                   "primary_birth_date_day" => 22,
                                   "primary_birth_date_month" => 3,
                                   "primary_birth_date_year" => 1929,
                                   "spouse_birth_date_day" => 2,
                                   "spouse_birth_date_month" => 9,
                                   "spouse_birth_date_year" => 1929,
                                   "filing_status" => "married_filing_jointly",
                                   "filing_status_note" => nil
                               })

    end
  end
end
