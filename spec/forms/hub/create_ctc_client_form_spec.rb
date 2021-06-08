require "rails_helper"

RSpec.describe Hub::CreateCtcClientForm do
  describe "#new" do
    it "initializes with empty tax_return objects for each valid filing year" do
      expect(described_class.new.tax_returns.map(&:year)).to eq(TaxReturn.filing_years)
    end
  end

  describe "#save" do
    let(:vita_partner) { create :vita_partner, name: "Caravan Palace" }
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
        sms_phone_number: "500-555-(0006)",
        street_address: "972 Mission St.",
        city: "San Francisco",
        state: "CA",
        zip_code: "94103",
        sms_notification_opt_in: sms_opt_in,
        email_notification_opt_in: email_opt_in,
        spouse_first_name: "Newly",
        spouse_last_name: "Wed",
        spouse_email_address: "spouse@example.com",
        spouse_last_four_ssn: "5678",
        filing_joint: "yes",
        timezone: "America/Chicago",
        state_of_residence: "CA",
        service_type: "drop_off",
        signature_method: "online",
        primary_last_four_ssn: "1234",
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
          described_class.new(params).save(current_user)
        end.to change(Client, :count).by 1
        client = Client.last
        expect(client.vita_partner).to eq vita_partner
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
            sms_body: I18n.t("drop_off_confirmation_message.sms.body", locale: "en"),
            email_body: I18n.t("drop_off_confirmation_message.email.body", locale: "en"),
            subject: I18n.t("drop_off_confirmation_message.email.subject", locale: "en"),
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
            sms_body: I18n.t("drop_off_confirmation_message.sms.body", locale: "es"),
            email_body: I18n.t("drop_off_confirmation_message.email.body", locale: "es"),
            subject: I18n.t("drop_off_confirmation_message.email.subject", locale: "es"),
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
        expect(intake.primary_last_four_ssn).to eq "1234"
        expect(intake.spouse_last_four_ssn).to eq "5678"
      end

      it "creates a single CTC 2020 tax return for the client" do
        expect do
          described_class.new(params).save(current_user)
        end.to change(TaxReturn, :count).by 1
        tax_return = Client.last.tax_returns.first
        intake = Intake.last
        expect(intake.needs_help_2020).to eq "yes"
        expect(intake.needs_help_2019).to eq "no"
        expect(intake.needs_help_2018).to eq "no"
        expect(intake.needs_help_2017).to eq "no"
        expect(tax_return.year).to eq 2020
        expect(tax_return.certification_level).to eq "basic"
        expect(tax_return.status).to eq "prep_ready_for_prep"
        expect(tax_return.client).to eq intake.client
        expect(tax_return.service_type).to eq "drop_off"
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
            event_id: Client.last.intake.visitor_id,
            event_name: "drop_off_submitted",
            data: fake_mixpanel_data
          ).exactly(1).times

          expect(MixpanelService).to have_received(:data_from).with([Client.last, tax_return, current_user])
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
    end
  end
end
