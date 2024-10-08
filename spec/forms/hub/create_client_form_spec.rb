require "rails_helper"

RSpec.describe Hub::CreateClientForm do

  let(:fake_current_tax_year) { 2023 }
  let(:fake_time) { DateTime.parse("2024-04-14") }
  let(:filing_years) { MultiTenantService.gyr.filing_years(fake_time) }

  around do |example|
    Timecop.freeze(fake_time) do
      example.run
    end
  end

  describe "#new" do
    it "initializes with empty tax_return objects for each valid filing year" do
      expect(described_class.new(filing_years).tax_returns.map(&:year)).to eq(filing_years)
    end
  end

  describe "#save" do
    let(:vita_partner) { create :site, name: "Caravan Palace" }
    let(:params) do
      {
        vita_partner_id: vita_partner.id,
        primary_first_name: "New",
        primary_last_name: "Name",
        preferred_name: "Newly",
        preferred_interview_language: preferred_interview_language,
        married: "yes",
        separated: "no",
        widowed: "no",
        lived_with_spouse: "yes",
        divorced: "no",
        divorced_year: "",
        separated_year: "",
        widowed_year: "",
        email_address: "someone@example.com",
        phone_number: "5005550006",
        sms_phone_number: "500-555-0006",
        street_address: "972 Mission St.",
        city: "San Francisco",
        state: "CA",
        zip_code: "94103",
        was_blind: "no",
        sms_notification_opt_in: sms_opt_in,
        email_notification_opt_in: email_opt_in,
        spouse_first_name: "Newly",
        spouse_last_name: "Wed",
        spouse_email_address: "spouse@example.com",
        spouse_ssn: "934769258",
        spouse_ssn_confirmation: "934769258",
        spouse_tin_type: "itin",
        spouse_was_blind: "yes",
        filing_joint: "yes",
        timezone: "America/Chicago",
        needs_help_previous_year_3: "yes",
        needs_help_previous_year_2: "yes",
        needs_help_previous_year_1: "yes",
        needs_help_current_year: "yes",
        state_of_residence: "CA",
        service_type: "drop_off",
        signature_method: "online",
        primary_ssn: "123456789",
        primary_ssn_confirmation: "123456789",
        primary_tin_type: "ssn",
        tax_returns_attributes: {
          "0" => {
            year: "2022",
            is_hsa: "1",
            certification_level: "basic"
          },
          "1" => {
            year: "2021",
            is_hsa: "0",
            certification_level: "basic"
          },
          "2" => {
            year: "2020",
            is_hsa: "1",
            certification_level: "basic"
          },
          "3" => {
            year: "2023",
            is_hsa: "0",
            certification_level: "advanced"
          },
        }
      }
    end

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
          described_class.new(filing_years, params).save(current_user)
        end.to change(Client, :count).by 1
        client = Client.last
        expect(client.vita_partner).to eq vita_partner
      end

      it "assigns client to an instance on the form object" do
        form = described_class.new(filing_years, params)
        form.save(current_user)
        expect(form.client).to eq Client.last
      end

      context "when the client's preferred language is not Spanish" do
        let(:preferred_interview_language) { "en" }
        let(:email_opt_in) { "yes" }

        it "sends the message in english" do
          described_class.new(filing_years, params).save(current_user)
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
          described_class.new(filing_years, params).save(current_user)

          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: Client.last,
            message: AutomatedMessage::SuccessfulSubmissionDropOff,
            locale: "es"
          )
        end
      end

      it "creates an intake" do
        expect do
          described_class.new(filing_years, params).save(current_user)
        end.to change(Intake, :count).by 1
        intake = Intake.last
        expect(intake.vita_partner).to eq vita_partner
        expect(intake.primary.ssn).to eq "123456789"
        expect(intake.spouse.ssn).to eq "934769258"
        expect(intake.spouse_was_blind).to eq "yes"
        expect(intake.primary_consented_to_service).to eq "yes"
        expect(intake.primary_consented_to_service_at).not_to be_nil
        expect(intake.completed_at).not_to be_nil
      end

      it "creates tax returns for each tax_return where _create is true" do
        expect do
          described_class.new(filing_years, params).save(current_user)
        end.to change(TaxReturn, :count).by 4
        tax_returns = Client.last.tax_returns
        intake = Intake.last
        expect(intake.needs_help_previous_year_2).to eq "yes"
        expect(intake.needs_help_previous_year_3).to eq "yes"
        expect(intake.needs_help_previous_year_1).to eq "yes"
        expect(intake.needs_help_current_year).to eq "yes"
        expect(tax_returns.map(&:year)).to match_array [2023, 2022, 2021, 2020]
        expect(tax_returns.map(&:client).uniq).to eq [intake.client]
        expect(tax_returns.map(&:service_type).uniq).to eq ["drop_off"]
      end

      context "mixpanel" do
        let(:fake_tracker) { double('mixpanel tracker') }
        let(:fake_mixpanel_data) { {} }

        before do
          allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
          allow(MixpanelService).to receive(:send_event)
        end

        it "sends drop_off_submitted event to Mixpanel" do
          described_class.new(filing_years, params).save(current_user)
          tax_returns = Client.last.tax_returns

          expect(MixpanelService).to have_received(:send_event).with(
            distinct_id: Client.last.intake.visitor_id,
            event_name: "drop_off_submitted",
            data: fake_mixpanel_data
          ).exactly(4).times

          expect(MixpanelService).to have_received(:data_from).with([Client.last, tax_returns[0], current_user])
          expect(MixpanelService).to have_received(:data_from).with([Client.last, tax_returns[1], current_user])
          expect(MixpanelService).to have_received(:data_from).with([Client.last, tax_returns[2], current_user])
        end
      end

      context "phone numbers" do
        it "normalizes phone_number and sms_phone_number" do
          described_class.new(filing_years,
                              params.update(sms_phone_number: "650-555-1212", phone_number: "(650) 555-1212")).save(current_user)
          client = Client.last
          expect(client.intake.sms_phone_number).to eq "+16505551212"
          expect(client.intake.phone_number).to eq "+16505551212"
        end
      end

      context "when associated models are not valid" do
        let(:form) { described_class.new(filing_years, params) }

        before do
          params[:sms_phone_number] = nil
          allow(form).to receive(:valid?).and_return true
        end

        it "does not save the associations" do
          expect { form.save(current_user) }.to raise_error ActiveRecord::RecordInvalid
        end
      end
    end

    context "validations" do
      context "with an invalid email" do
        before { params[:email_address] = "someone@example" }
        let(:form) { described_class.new(filing_years, params) }

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
          expect(described_class.new(filing_years, params).valid?).to eq false
        end

        it "pushes errors for attribute into the errors" do
          obj = described_class.new(filing_years, params)
          obj.valid?
          expect(obj.errors[:vita_partner_id]).to eq ["Can't be blank."]
        end
      end

      context "preferred_interview_language" do
        let(:form) { described_class.new(filing_years, params) }

        context "when nil" do
          before do
            params[:preferred_interview_language] = nil
            form.valid?
          end

          it "adds an error to the field" do
            expect(form.errors[:preferred_interview_language]).to eq ["Can't be blank."]
          end
        end

        context "when blank" do
          before do
            params[:preferred_interview_language] = ""
            form.valid?
          end

          it "adds an error to the field" do
            expect(form.errors[:preferred_interview_language]).to eq ["Can't be blank."]
          end
        end
      end

      context "state_of_residence" do
        context "when not provided" do
          before do
            params[:state_of_residence] = nil
          end

          it "is not valid" do
            expect(described_class.new(filing_years, params).valid?).to eq false
          end

          it "adds an error to the attribute" do
            obj = described_class.new(filing_years, params)
            obj.valid?
            expect(obj.errors[:state_of_residence]).to eq ["Please select a state from the list."]
          end
        end

        context "when not in list of US States/territories" do
          before do
            params[:state_of_residence] = "France"
          end

          it "adds an error to the attribute" do
            obj = described_class.new(filing_years, params)
            obj.valid?
            expect(obj.errors[:state_of_residence]).to eq ["Please select a state from the list."]
          end
        end
      end

      context "signature method" do
        before do
          params[:signature_method] = nil
        end

        it "is required" do
          expect(described_class.new(filing_years, params).valid?).to eq false
        end

        it "pushes errors for signature method into the errors" do
          obj = described_class.new(filing_years, params)
          obj.valid?
          expect(obj.errors[:signature_method]).to include "Can't be blank."
        end
      end

      context "tax returns attributes" do
        context "when there are some blank required fields" do
          before do
            params[:tax_returns_attributes]["1"][:certification_level] = ""
          end

          it "is not valid" do
            expect(described_class.new(filing_years, params).valid?).to eq false
          end

          it "adds an error to the attribute" do
            obj = described_class.new(filing_years, params)
            obj.valid?
            expect(obj.errors[:tax_returns_attributes]).to eq ["Please provide all required fields for tax returns: certification level."]
          end
        end
      end

      context "when no tax return years are selected for prep" do
        before do
          params[:needs_help_previous_year_3] = "no"
          params[:needs_help_previous_year_2] = "no"
          params[:needs_help_previous_year_1] = "no"
          params[:needs_help_current_year] = "no"
        end

        it "is not valid" do
          expect(described_class.new(filing_years, params).valid?).to eq false
        end

        it "pushes an error" do
          obj = described_class.new(filing_years, params)
          obj.valid?
          expect(obj.errors[:tax_returns_attributes]).to include "Please pick at least one year."
        end
      end
    end
  end
end
