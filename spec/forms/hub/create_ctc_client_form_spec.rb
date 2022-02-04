require "rails_helper"

RSpec.describe Hub::CreateCtcClientForm do
  describe "#save" do
    let(:vita_partner) { create :organization, name: "Caravan Palace" }
    let(:params) do
      {
        vita_partner_id: vita_partner.id,
        primary_first_name: "New",
        primary_last_name: "Name",
        preferred_name: "Newly",
        preferred_interview_language: preferred_interview_language,
        email_address: "someone@example.com",
        phone_number: "5005550006",
        sms_phone_number: "500-555-0006",
        primary_birth_date_year: "1963",
        primary_birth_date_month: "9",
        primary_birth_date_day: "10",
        street_address: "972 Mission St.",
        city: "San Francisco",
        state: "CA",
        zip_code: "94103",
        sms_notification_opt_in: sms_opt_in,
        email_notification_opt_in: email_opt_in,
        spouse_first_name: "Newly",
        spouse_last_name: "Wed",
        spouse_email_address: "spouse@example.com",
        spouse_tin_type: "ssn",
        spouse_ssn: '111224444',
        spouse_ssn_confirmation: '111224444',
        spouse_birth_date_year: "1962",
        spouse_birth_date_month: "9",
        spouse_birth_date_day: "7",
        timezone: "America/Chicago",
        signature_method: "online",
        primary_tin_type: "ssn",
        primary_ssn: '111223333',
        primary_ssn_confirmation: '111223333',
        filing_status: "single",
        filing_status_note: "Didn't get married until 2021",
        account_type: "checking",
        routing_number: "1234567",
        routing_number_confirmation: "1234567",
        account_number: "1234567",
        account_number_confirmation: "1234567",
        bank_name: "Bank of America",
        eip1_amount_received: "$280",
        eip2_amount_received: "$250",
        eip1_and_2_amount_received_confidence: "sure",
        refund_payment_method: refund_payment_method,
        navigator_name: "Tax Seasonson",
        navigator_has_verified_client_identity: true,
        with_passport_photo_id: "1",
        with_itin_taxpayer_id: "1",
        primary_ip_pin: "123456",
        spouse_ip_pin: "234567",
      }
    end

    let(:refund_payment_method) { "direct_deposit" }
    let(:preferred_interview_language) { "es" }
    let(:sms_opt_in) { "yes" }
    let(:email_opt_in) { "no" }
    let(:current_user) { create :user }

    before do
      allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
    end

    context "with valid params and context" do
      it "creates a client" do
        expect do
          described_class.new(params).save(current_user)
        end.to change(Client, :count).by 1
        client = Client.last
        expect(client.vita_partner).to eq vita_partner
      end

      it "stores client bank info on the intake" do
        described_class.new(params).save(current_user)
        client = Client.last
        expect(client.intake.bank_account.account_number).to eq params[:account_number]
        expect(client.intake.bank_account.routing_number).to eq params[:routing_number]
        expect(client.intake.bank_account.account_type).to eq "checking"
        expect(client.intake.bank_account.bank_name).to eq "Bank of America"
      end

      it "stores the primary clients date of birth" do
        described_class.new(params).save(current_user)
        expect(Client.last.intake.primary_birth_date).to eq Date.new(1963, 9, 10)
      end

      it "stores the spouses clients date of birth" do
        described_class.new(params).save(current_user)
        expect(Client.last.intake.spouse_birth_date).to eq Date.new(1962, 9, 7)
      end

      it "stores recovery rebate credit amount on the intake" do
        described_class.new(params).save(current_user)
        client = Client.last
        expect(client.intake.eip1_amount_received).to eq 280
        expect(client.intake.eip2_amount_received).to eq 250
        expect(client.intake.eip1_and_2_amount_received_confidence).to eq "sure"
      end

      it "stores primary SSN and also the last 4 in a separate column" do
        described_class.new(params).save(current_user)
        client = Client.last
        expect(client.intake.primary_ssn).to eq('111223333')
        expect(client.intake.primary_last_four_ssn).to eq('3333')
      end

      it "stores spouse SSN and also the last 4 in a separate column" do
        described_class.new(params).save(current_user)
        client = Client.last
        expect(client.intake.spouse_ssn).to eq('111224444')
        expect(client.intake.spouse_last_four_ssn).to eq('4444')
      end

      it "stores the photo ID types used" do
        described_class.new(params).save(current_user)
        client = Client.last
        expect(client.intake.with_passport_photo_id).to be_truthy
      end

      it "stores the taxpayer ID types used" do
        described_class.new(params).save(current_user)
        client = Client.last
        expect(client.intake.with_itin_taxpayer_id).to be_truthy
      end

      it "assigns client to an instance on the form object" do
        form = described_class.new(params)
        form.save(current_user)
        expect(form.client).to eq Client.last
      end

      context "when the client's preferred language is not Spanish" do
        let(:preferred_interview_language) { "en" }
        let(:email_opt_in) { "yes" }

        it "sends the message in english" do
          described_class.new(params).save(current_user)
          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: Client.last,
            message: AutomatedMessage::SuccessfulSubmissionDropOff,
            locale: "en"
          )
        end
      end

      context "when the client's preferred language is Spanish" do
        let(:preferred_interview_language) { "es" }
        let(:email_opt_in) { "yes" }

        it "sends the message in spanish" do
          described_class.new(params).save(current_user)

          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: Client.last,
            message: AutomatedMessage::SuccessfulSubmissionDropOff,
            locale: "es"
          )
        end
      end

      it "creates an intake" do
        expect do
          described_class.new(params).save(current_user)
        end.to change(Intake, :count).by 1
        intake = Intake.last
        expect(intake.vita_partner).to eq vita_partner
        expect(intake.timezone).to eq "America/Chicago"
      end

      it "creates a single CTC 2021 tax return for the client" do
        expect do
          described_class.new(params).save(current_user)
        end.to change(TaxReturn, :count).by 1
        tax_return = Client.last.tax_returns.first
        intake = Intake.last
        expect(tax_return.year).to eq 2021
        expect(tax_return.certification_level).to eq "basic"
        expect(tax_return.current_state).to eq "prep_ready_for_prep"
        expect(tax_return.client).to eq intake.client
        expect(tax_return.service_type).to eq "drop_off"
        expect(tax_return.filing_status).to eq "single"
        expect(tax_return.filing_status_note).to eq "Didn't get married until 2021"
        expect(tax_return.is_ctc).to be_truthy
      end

      context "mixpanel" do
        let(:fake_tracker) { double('mixpanel tracker') }
        let(:fake_mixpanel_data) { {} }

        before do
          allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
          allow(MixpanelService).to receive(:send_event)
        end

        it "sends drop_off_submitted event to Mixpanel" do
          described_class.new(params).save(current_user)
          tax_return = Client.last.tax_returns.first

          expect(MixpanelService).to have_received(:send_event).with(
            distinct_id: Client.last.intake.visitor_id,
            event_name: "drop_off_submitted",
            data: fake_mixpanel_data
          ).exactly(1).times

          expect(MixpanelService).to have_received(:data_from).with([Client.last, tax_return, current_user])
        end
      end

      context "with system note" do
        it "creates a system note for identity verification" do
          expect {
            described_class.new(params).save(current_user)
          }.to change(SystemNote, :count).by(1)
        end
      end

      context "phone numbers" do
        it "normalizes phone_number and sms_phone_number" do
          described_class.new(params.update(sms_phone_number: "650-555-1212", phone_number: "(650) 555-1212")).save(current_user)
          client = Client.last
          expect(client.intake.sms_phone_number).to eq "+16505551212"
          expect(client.intake.phone_number).to eq "+16505551212"
        end
      end

      context "when associated models are not valid" do
        let(:form) { described_class.new(params) }

        before do
          params[:sms_phone_number] = nil
          allow(form).to receive(:valid?).and_return true
        end

        it "does not save the associations" do
          expect { form.save(current_user) }.to raise_error ActiveRecord::RecordInvalid
        end
      end

      context "IP PINs" do
        it "saves the primary and spouse IP PINs" do
          described_class.new(params).save(current_user)
          intake = Intake.last
          expect(intake.primary_ip_pin).to eq '123456'
          expect(intake.spouse_ip_pin).to eq '234567'
        end
      end

      context "refund payment method is check" do
        let(:refund_payment_method) { "check" }

        it "stores client bank info on the intake" do
          described_class.new(params).save(current_user)
          client = Client.last
          expect(client.intake.bank_account).to eq nil
        end
      end
    end

    context "with dependents" do
      let(:dependents_attributes) do
        {
          dependents_attributes: {
            "0" => {
              id: nil,
              first_name: "Maria",
              last_name: "Mango",
              birth_date_month: "May",
              birth_date_day: "9",
              birth_date_year: "2013",
              relationship: "child",
              ip_pin: "345678",
              tin_type: "ssn",
              ssn: '111-22-3333',
              ssn_confirmation: '111-22-3333',
            }
          }
        }
      end

      it "successfully saves the client with associated dependents" do
        expect do
          described_class.new(params.merge(dependents_attributes)).save(current_user)
        end.to change(Client, :count).by 1
        client = Client.last
        expect(client.intake.dependents.count).to eq 1
        expect(client.vita_partner).to eq vita_partner
        expect(client.intake.dependents.last.ip_pin).to eq "345678"
      end
    end

    context "validations" do
      context "with an invalid email" do
        before { params[:email_address] = "someone@example" }
        let(:form) { described_class.new(params) }

        it "is not valid and adds an error to the email field" do
          expect(form).not_to be_valid
          expect(form.errors).to include :email_address
        end
      end

      context "vita_partner_id" do
        before do
          params[:vita_partner_id] = nil
        end

        it "is not valid" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes errors for attribute into the errors" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:vita_partner_id]).to eq ["Can't be blank."]
        end
      end

      context "birth_dates" do
        context "no birth date is provided" do
          before do
            params[:spouse_birth_date_year] = nil
            params[:spouse_birth_date_month] = nil
            params[:spouse_birth_date_day] = nil
            params[:filing_status] = "married_filing_jointly"
          end

          it "is not valid" do
            expect(described_class.new(params).valid?).to eq false
          end

          it "pushes errors for attribute into the errors" do
            obj = described_class.new(params)
            obj.valid?
            expect(obj.errors[:spouse_birth_date]).to eq ["Please enter a valid date."]
          end
        end

        context "the birth date is missing some part" do
          before do
            params[:primary_birth_date_year] = "1972"
            params[:primary_birth_date_month] = ""
            params[:primary_birth_date_day] = "11"
          end
          it "is not valid" do
            expect(described_class.new(params).valid?).to eq false
          end

          it "pushes errors for attribute into the errors" do
            obj = described_class.new(params)
            obj.valid?
            expect(obj.errors[:primary_birth_date]).to eq ["Please enter a valid date."]
          end
        end
      end

      context "signature method" do
        before do
          params[:signature_method] = nil
        end

        it "is required" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes errors for signature method into the errors" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:signature_method]).to include "Can't be blank."
        end
      end

      context "filing status" do
        before do
          params[:filing_status] = nil
        end

        it "is required" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes errors for signature method into the errors" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:filing_status]).to include "Can't be blank."
        end
      end

      context "photo ID type" do
        before do
          params[:with_drivers_license_photo_id] = "0"
          params[:with_passport_photo_id] = "0"
          params[:with_other_state_photo_id] = "0"
          params[:with_vita_approved_photo_id] = "0"
        end

        it "must have at least one photo ID type selected" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes errors for photo ID type into the errors" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:photo_id_type]).to include "Please select at least one photo ID type"
        end
      end

      context "taxpayer ID type" do
        before do
          params[:with_social_security_taxpayer_id] = "0"
          params[:with_itin_taxpayer_id] = "0"
          params[:with_vita_approved_photo_id] = "0"
        end

        it "must have at least one taxpayer ID type selected" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes errors for taxpayer ID type into the errors" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:taxpayer_id_type]).to include "Please select at least one taxpayer ID type"
        end
      end

      context "refund payment method" do
        before do
          params[:refund_payment_method] = nil
        end

        it "is required" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes errors for ctc refund method into the errors" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:refund_payment_method]).to include "Can't be blank."
        end
      end

      context "when the CTC refund method is check" do
        before do
          params[:refund_payment_method] = "check"
        end

        context "account_number" do
          before do
            params[:account_number] = nil
          end

          it "is not required" do
            obj = described_class.new(params)
            obj.valid?
            expect(obj.errors[:account_number]).to be_blank
          end
        end
      end

      context "when refund payment method is direct deposit" do
        before do
          params[:refund_payment_method] = "direct_deposit"
        end

        context "account_number" do
          before do
            params[:account_number] = nil
          end
          it "is required" do
            obj = described_class.new(params)
            obj.valid?
            expect(obj.errors[:account_number]).to include "Can't be blank."
          end
        end

        context "routing_number" do
          before do
            params[:routing_number] = nil
          end
          it "is required" do
            obj = described_class.new(params)
            obj.valid?
            expect(obj.errors[:routing_number]).to include "Can't be blank."
          end
        end

        context "routing_number_confirmation" do
          context "when routing_number is provided" do
            before do
              params[:routing_number] = "1234565"
              params[:routing_number_confirmation] = nil
            end
            it "is required" do
              obj = described_class.new(params)
              obj.valid?
              expect(obj.errors[:routing_number_confirmation]).to include "Can't be blank."
            end
          end

          context "when routing confirmation is provided but does not match" do
            before do
              params[:routing_number] = "1234565"
              params[:routing_number_confirmation] = "2234565"
            end
            it "provides an error" do
              obj = described_class.new(params)
              obj.valid?
              expect(obj.errors[:routing_number_confirmation]).to include "doesn't match Routing number"
            end
          end
        end

        context "account_number_confirmation" do
          context "when account_number is provided" do
            before do
              params[:account_number] = "1234565"
              params[:account_number_confirmation] = nil
            end
            it "is required" do
              obj = described_class.new(params)
              obj.valid?
              expect(obj.errors[:account_number_confirmation]).to include "Can't be blank."
            end
          end

          context "when account confirmation is provided but does not match" do
            before do
              params[:account_number] = "1234565"
              params[:account_number_confirmation] = "2234565"
            end
            it "provides an error" do
              obj = described_class.new(params)
              obj.valid?
              expect(obj.errors[:account_number_confirmation]).to include "doesn't match Account number"
            end
          end
        end
      end

      context "IP PINs" do
        before do
          params[:primary_ip_pin] = "123"
          params[:spouse_ip_pin] = nil
        end

        it "can be blank but must be a 6 digit number" do
          obj = described_class.new(params)
          expect(obj.valid?).to eq false
          expect(obj.errors[:primary_ip_pin]).to include I18n.t('validators.ip_pin')
          expect(obj.errors[:spouse_ip_pin]).to eq []
        end

        context "for dependents" do
          let(:dependents_attributes) do
            {
              dependents_attributes: {
                "0" => {
                  id: nil,
                  first_name: "Maria",
                  last_name: "Mango",
                  birth_date_month: "May",
                  birth_date_day: "9",
                  birth_date_year: "2013",
                  relationship: "child",
                  tin_type: "ssn",
                  ssn: "111-22-4444",
                  ip_pin: "3456",
                }
              }
            }
          end

          context "when there are no other validation errors" do
            it "states that all IP PINs must be a 6 digit number" do
              obj = described_class.new(params.merge(dependents_attributes))
              expect(obj.valid?).to eq false
              expect(obj.dependents.last.errors[:ip_pin]).to include "IP PINs must be a 6 digit number."
            end
          end

          context "when there are other validation errors" do
            before do
              dependents_attributes[:dependents_attributes]["0"][:relationship] = nil
            end

            it "can present validation errors for multiple fields" do
              obj = described_class.new(params.merge(dependents_attributes))
              expect(obj.valid?).to eq false
              new_dependent = obj.dependents.last
              expect(new_dependent.errors[:relationship]).to include "Can't be blank."
              expect(new_dependent.errors[:ip_pin]).to include "IP PINs must be a 6 digit number."
            end
          end
        end
      end

      context "identification numbers" do
        context "when tin type is ssn" do
          context "when ssn format is wrong" do
            before do
              params[:primary_ssn] = "666-99-9999"
              params[:primary_ssn_confirmation] = "666-99-9999"
            end

            it "it is not valid" do
              expect(described_class.new(params)).to_not be_valid
            end
          end
        end

        context "when tin type is itin" do
          context "when the itin format is wrong" do
            before do
              params[:primary_tin_type] = "itin"
              params[:primary_ssn] = "900-93-9999"
              params[:primary_ssn_confirmation] = "900-93-9999"
            end

            it "it is not valid" do
              expect(described_class.new(params)).to_not be_valid
            end
          end

          context "when the itin format is correct" do
            before do
              params[:primary_tin_type] = "itin"
              params[:primary_ssn] = "900-78-9999"
              params[:primary_ssn_confirmation] = "900-78-9999"
            end

            it "is valid" do
              expect(described_class.new(params)).to be_valid
            end
          end
        end

        context "for dependents" do
          let(:dependents_attributes) do
            {
              dependents_attributes: {
                "0" => {
                  id: nil,
                  first_name: "Maria",
                  last_name: "Mango",
                  birth_date_month: "May",
                  birth_date_day: "9",
                  birth_date_year: "2013",
                  relationship: "child",
                  ip_pin: "345678",
                  tin_type: "ssn",
                  ssn: '111-22-3333',
                  ssn_confirmation: '111-22-3333',
                }
              }
            }
          end

          context "when tin type is ssn" do
            context "when ssn format is wrong" do
              before do
                dependents_attributes[:dependents_attributes]["0"][:ssn] = "666-99-9999"
                dependents_attributes[:dependents_attributes]["0"][:ssn_confirmation] = "666-99-9999"
              end

              it "it is not valid" do
                expect(described_class.new(params.merge(dependents_attributes))).to_not be_valid
              end
            end
          end

          context "when tin type is itin" do
            context "when the itin format is wrong" do
              before do
                dependents_attributes[:dependents_attributes]["0"][:tin_type] = "itin"
                dependents_attributes[:dependents_attributes]["0"][:ssn] = "900-93-9999"
                dependents_attributes[:dependents_attributes]["0"][:ssn_confirmation] = "900-93-9999"
              end

              it "it is not valid" do
                expect(described_class.new(params.merge(dependents_attributes))).to_not be_valid
              end
            end

            context "when the itin format is correct" do
              before do
                dependents_attributes[:dependents_attributes]["0"][:tin_type] = "itin"
                dependents_attributes[:dependents_attributes]["0"][:ssn] = "900-78-9999"
                dependents_attributes[:dependents_attributes]["0"][:ssn_confirmation] = "900-78-9999"
              end

              it "is valid" do
                expect(described_class.new(params.merge(dependents_attributes))).to be_valid
              end
            end
          end
        end
      end
    end
  end
end
