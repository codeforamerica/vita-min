require "rails_helper"

RSpec.describe StateFile::NotificationPreferencesForm do
  let!(:intake) { create :state_file_az_intake }

  describe "#valid?" do
    context "when sms_notification_opt_in is present" do
      context "with no existing phone number" do
        let(:valid_params) do
          {
            sms_notification_opt_in: "yes",
            phone_number: "+14155551212"
          }
        end

        subject(:form) { described_class.new(intake, valid_params) }

        it "is valid" do
          expect(form).to be_valid
        end

        context "when phone number is not in e164 format" do
          let(:invalid_params) do
            {
              sms_notification_opt_in: "yes",
              phone_number: "415555121"
            }
          end
          subject(:form) { described_class.new(intake, invalid_params) }

          it "is invalid" do
            form.valid?
            expect(form).not_to be_valid
          end

          it "adds an error to the phone_number attribute" do
            form.valid?
            expect(form.errors[:phone_number]).to include "Please enter a valid phone number."
          end
        end

        context "when phone number is blank" do
          let(:invalid_params) do
            {
              sms_notification_opt_in: "yes",
              phone_number: ""
            }
          end
          subject(:form) { described_class.new(intake, invalid_params) }

          it "is invalid" do
            form.valid?
            expect(form).not_to be_valid
          end

          it "adds an error to the phone_number attribute" do
            form.valid?
            expect(form.errors[:phone_number]).to include "Please enter a valid phone number."
          end
        end
      end

      context "with existing phone number" do
        let!(:intake) { create :state_file_az_intake, phone_number: "+14155551212" }

        let(:params) do
          {
            sms_notification_opt_in: "yes",
            phone_number: "" # Empty phone number should be valid when there's an existing one
          }
        end

        subject(:form) { described_class.new(intake, params) }

        it "is valid and preserves the existing phone number" do
          expect(form).to be_valid
          form.save
          expect(intake.reload.phone_number).to eq "+14155551212"
          expect(intake.sms_notification_opt_in).to eq "yes"
        end
      end
    end

    context "when email_notification_opt_in is present" do
      context "with no existing email address" do
        let(:valid_params) do
          {
            email_notification_opt_in: "yes",
            email_address: "test@example.com"
          }
        end

        subject(:form) { described_class.new(intake, valid_params) }

        it "is valid and updates the intake with provided attributes" do
          expect(form).to be_valid
          expect { form.save }.to change(intake, :email_notification_opt_in).from("unfilled").to("yes")
                                                                            .and change(intake, :email_address).to("test@example.com")
        end

        context "when email address is invalid" do
          let(:invalid_params) do
            {
              email_notification_opt_in: "yes",
              email_address: "invalid-email"
            }
          end
          subject(:form) { described_class.new(intake, invalid_params) }

          it "is invalid and adds an error to the email_address attribute" do
            form.valid?
            expect(form).not_to be_valid
            expect(form.errors[:email_address]).to be_present
          end
        end

        context "when email address is missing" do
          let(:invalid_params) do
            {
              email_notification_opt_in: "yes",
              email_address: ""
            }
          end
          subject(:form) { described_class.new(intake, invalid_params) }

          it "is invalid and adds a presence error to the email_address attribute" do
            form.valid?
            expect(form).not_to be_valid
            expect(form.errors[:email_address]).to include "Can't be blank."
          end
        end
      end

      context "with existing email address" do
        let!(:intake) { create :state_file_az_intake, email_address: "existing@example.com" }

        let(:params) do
          {
            email_notification_opt_in: "yes",
            email_address: "" # Empty email address should be valid when there's an existing one
          }
        end

        subject(:form) { described_class.new(intake, params) }

        it "is valid and preserves the existing email" do
          expect(form).to be_valid
          form.save
          expect(intake.reload.email_address).to eq "existing@example.com"
          expect(intake.email_notification_opt_in).to eq "yes"
        end
      end
    end

    context "when sms_notification_opt_in is not present" do
      let(:invalid_params) do
        {
          email_notification_opt_in: "yes",
          email_address: "test@example.com",
          phone_number: "415555121"
        }
      end
      subject(:form) { described_class.new(intake, invalid_params) }

      it "does not validate phone number" do
        form.valid?
        expect(form).to be_valid
      end

      it "updates the intake with the provided attributes" do
        expect { form.save }.to change(intake, :email_notification_opt_in).from("unfilled").to("yes")
      end
    end

    context "when email_notification_opt_in is not present" do
      context "with existing email address" do
        let!(:intake) { create :state_file_az_intake, email_address: "existing@example.com" }

        let(:params) do
          {
            sms_notification_opt_in: "yes",
            phone_number: "+14155551212",
            email_address: ""
          }
        end

        subject(:form) { described_class.new(intake, params) }

        it "is valid and preserves the existing email" do
          expect(form).to be_valid
          form.save
          expect(intake.reload.email_address).to eq "existing@example.com"
        end
      end
    end

    context "when neither are present" do
      let(:invalid_params) do
        {
          phone_number: "415555121",
          email_notification_opt_in: "no"
        }
      end
      subject(:form) { described_class.new(intake, invalid_params) }

      it 'is invalid' do
        form.valid?
        expect(form).not_to be_valid
      end
    end
  end

  describe "#save" do
    before do
      messaging_service = instance_double(StateFile::MessagingService)
      allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)
      allow(messaging_service).to receive(:send_message)
    end
    context "when setting notification preferences for the first time" do
      let!(:intake) { create :state_file_az_intake, sms_notification_opt_in: "unfilled", email_notification_opt_in: "unfilled" }

      context "when opting into email notifications" do
        let(:params) do
          {
            email_notification_opt_in: "yes",
            email_address: "test@example.com"
          }
        end
        subject(:form) { described_class.new(intake, params) }

        it "sends welcome message" do
          expect(StateFile::MessagingService).to receive(:new).with(
            message: StateFile::AutomatedMessage::Welcome,
            intake: intake,
            sms: false,
            email: true,
            body_args: { intake_id: intake.id },
            locale: :en
          )
          form.save
        end
      end

      context "when opting into SMS notifications" do
        let(:params) do
          {
            sms_notification_opt_in: "yes",
            phone_number: "+14155551212"
          }
        end
        subject(:form) { described_class.new(intake, params) }

        it "sends a welcome SMS" do
          expect(StateFile::MessagingService).to receive(:new).with(
            message: StateFile::AutomatedMessage::Welcome,
            intake: intake,
            sms: true,
            email: false,
            body_args: { intake_id: intake.id },
            locale: :en
          )
          form.save
        end
      end

      context "when opting into both SMS and email notifications" do
        let(:params) do
          {
            sms_notification_opt_in: "yes",
            phone_number: "+14155551212",
            email_notification_opt_in: "yes",
            email_address: "test@example.com"
          }
        end
        subject(:form) { described_class.new(intake, params) }

        it "sends both welcome email and SMS" do
          expect(StateFile::MessagingService).to receive(:new).with(
            message: StateFile::AutomatedMessage::Welcome,
            intake: intake,
            sms: true,
            email: true,
            body_args: { intake_id: intake.id },
            locale: :en
          )
          form.save
        end
      end

      context "when updating existing notification preferences" do
        let!(:intake) { 
          create :state_file_az_intake,
                               sms_notification_opt_in: "no",
                               email_notification_opt_in: "no" }

        context "when changing notification preferences" do
          let(:params) do
            {
              sms_notification_opt_in: "yes",
              phone_number: "+14155551212"
            }
          end
          subject(:form) { described_class.new(intake, params) }

          it "does not send welcome message" do
            expect(StateFile::MessagingService).not_to receive(:new)
            form.save
          end
        end
      end
    end
  end
end