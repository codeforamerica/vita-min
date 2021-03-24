require "rails_helper"

RSpec.describe Hub::CreateClientForm do
  describe "#new" do
    it "initializes with empty tax_return objects for each valid filing year" do
      expect(described_class.new.tax_returns.map(&:year)).to eq(TaxReturn.filing_years)
    end
  end

  describe "#save" do
    let(:vita_partner) { create :vita_partner }
    let(:params) do
      {
          vita_partner_id: vita_partner.id,
          primary_first_name: "New",
          primary_last_name: "Name",
          preferred_name: "Newly",
          preferred_interview_language: "es",
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
          sms_notification_opt_in: "yes",
          email_notification_opt_in: "no",
          spouse_first_name: "Newly",
          spouse_last_name: "Wed",
          spouse_email_address: "spouse@example.com",
          spouse_last_four_ssn: "5678",
          filing_joint: filing_joint,
          timezone: "America/Chicago",
          needs_help_2020: "yes",
          needs_help_2019: "yes",
          needs_help_2018: "yes",
          needs_help_2017: "no",
          state_of_residence: "CA",
          service_type: "drop_off",
          signature_method: "online",
          primary_last_four_ssn: "1234",
          tax_returns_attributes: {
              "0" => {
                  year: "2020",
                  is_hsa: "1",
                  certification_level: "basic"
              },
              "1" => {
                  year: "2019",
                  is_hsa: "0",
                  certification_level: "basic"
              },
              "2" => {
                  year: "2018",
                  is_hsa: "1",
                  certification_level: "basic"
              },
              "3" => {
                  year: "2017",
                  is_hsa: "0",
                  certification_level: "advanced"
              },
          }
      }
    end
    let(:filing_joint) { "yes" }
    let(:current_user) { create :user }
    let(:fake_time) { Time.utc(2021, 2, 6, 0, 0, 0) }
    let(:ip_address) { "127.0.0.1" }

    context "with valid params and context" do
      it "creates a client" do
        expect do
          described_class.new(params).save(current_user, ip_address)
        end.to change(Client, :count).by 1
        client = Client.last
        expect(client.vita_partner).to eq vita_partner
      end

      it "assigns client to an instance on the form object" do
        form = described_class.new(params)
        form.save(current_user, ip_address)
        expect(form.client).to eq Client.last
      end

      it "creates an intake" do
        expect do
          described_class.new(params).save(current_user, ip_address)
        end.to change(Intake, :count).by 1
        intake = Intake.last
        expect(intake.vita_partner).to eq vita_partner
        expect(intake.primary_last_four_ssn).to eq "1234"
        expect(intake.spouse_last_four_ssn).to eq "5678"
      end

      it "creates tax returns for each tax_return where _create is true" do
        expect do
          described_class.new(params).save(current_user, ip_address)
        end.to change(TaxReturn, :count).by 3
        tax_returns = Client.last.tax_returns
        intake = Intake.last
        expect(intake.needs_help_2020).to eq "yes"
        expect(intake.needs_help_2019).to eq "yes"
        expect(intake.needs_help_2018).to eq "yes"
        expect(intake.needs_help_2017).to eq "no"
        expect(tax_returns.map(&:year)).to eq [2020, 2019, 2018]
        expect(tax_returns.map(&:client).uniq).to eq [intake.client]
        expect(tax_returns.map(&:service_type).uniq).to eq ["drop_off"]
      end

      it "sets the consented at timestamp on the intake" do
        Timecop.freeze(fake_time) do
          described_class.new(params).save(current_user, ip_address)
        end

        intake = Intake.last
        expect(intake.primary_consented_to_service_at).to eq fake_time
        expect(intake.primary_consented_to_service).to eq 'yes'
        expect(intake.primary_consented_to_service_ip).to eq ip_address

        expect(intake.spouse_consented_to_service_at).to eq fake_time
        expect(intake.spouse_consented_to_service).to eq 'yes'
        expect(intake.spouse_consented_to_service_ip).to eq ip_address
      end

      context "mixpanel" do
        let(:fake_tracker) { double('mixpanel tracker') }
        let(:fake_mixpanel_data) { {} }

        before do
          allow(MixpanelService).to receive(:data_from).and_return(fake_mixpanel_data)
          allow(MixpanelService).to receive(:send_event)
        end

        it "sends drop_off_submitted event to Mixpanel" do
          described_class.new(params).save(current_user, ip_address)
          tax_returns = Client.last.tax_returns

          expect(MixpanelService).to have_received(:send_event).with(
            event_id: Client.last.intake.visitor_id,
            event_name: "drop_off_submitted",
            data: fake_mixpanel_data
          ).exactly(3).times

          expect(MixpanelService).to have_received(:data_from).with([Client.last, tax_returns[0], current_user])
          expect(MixpanelService).to have_received(:data_from).with([Client.last, tax_returns[1], current_user])
          expect(MixpanelService).to have_received(:data_from).with([Client.last, tax_returns[2], current_user])
        end
      end

      context "phone numbers" do
        it "normalizes phone_number and sms_phone_number" do
          described_class.new(params.update(sms_phone_number: "650-555-1212", phone_number: "(650) 555-1212")).save(current_user, ip_address)
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
          expect { form.save(current_user, ip_address) }.to raise_error ActiveRecord::RecordInvalid
        end
      end

      context "when the client is not filing jointly" do
        let(:filing_joint) { "no" }

        it "does not set the spouse consented at timestamp on the intake" do
          Timecop.freeze(fake_time) do
            described_class.new(params).save(current_user, ip_address)
          end

          intake = Intake.last
          expect(intake.primary_consented_to_service_at).to eq fake_time
          expect(intake.primary_consented_to_service).to eq 'yes'
          expect(intake.primary_consented_to_service_ip).to eq ip_address

          expect(intake.spouse_consented_to_service_at).to eq nil
          expect(intake.spouse_consented_to_service).to eq "unfilled"
          expect(intake.spouse_consented_to_service_ip).to eq nil
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

      context "tax returns attributes" do
        context "when there are some blank required fields" do
          before do
            params[:tax_returns_attributes]["0"][:is_hsa] = nil
            params[:tax_returns_attributes]["0"][:certification_level] = ""
          end

          it "is not valid" do
            expect(described_class.new(params).valid?).to eq false
          end

          it "adds an error to the attribute" do
            obj = described_class.new(params)
            obj.valid?
            expect(obj.errors[:tax_returns_attributes]).to eq ["Please provide all required fields for tax returns: certification level, is HSA."]
          end
        end
      end

      context "when no tax return years are selected for prep" do
        before do
          params[:needs_help_2017] = "no"
          params[:needs_help_2018] = "no"
          params[:needs_help_2019] = "no"
          params[:needs_help_2020] = "no"
        end

        it "is not valid" do
          expect(described_class.new(params).valid?).to eq false
        end

        it "pushes an error" do
          obj = described_class.new(params)
          obj.valid?
          expect(obj.errors[:tax_returns_attributes]).to include "Please pick at least one year."
        end
      end
    end
  end
end
