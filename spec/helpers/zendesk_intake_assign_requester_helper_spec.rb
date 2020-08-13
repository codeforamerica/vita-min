require "rails_helper"

RSpec.describe ZendeskIntakeAssignRequesterHelper do
  let(:email_opt_in) { "unfilled" }
  let(:sms_opt_in) { "unfilled" }
  let(:timezone) { "America/Chicago" }
  let(:intake) do
    create :intake,
           intake_ticket_requester_id: intake_ticket_requester_id,
           sms_notification_opt_in: sms_opt_in,
           email_notification_opt_in: email_opt_in,
           email_address: "cash@raining.money",
           phone_number: "14155551234",
           sms_phone_number: "14155551234",
           timezone: timezone
  end
  let(:service) do
    class AssignRequesterSampleService
      include ZendeskServiceHelper
      include ZendeskIntakeAssignRequesterHelper
      def initialize(intake)
        @intake = intake
      end
    end

    AssignRequesterSampleService.new(intake)
  end

  describe "#assign_requester" do
    let(:output_ticket_requester_id) { 2 }

    before do
      allow(service).to receive(:create_or_update_zendesk_user) { output_ticket_requester_id }
    end

    context "if requester is already assigned" do
      let(:intake_ticket_requester_id) { 1 }

      it "skips create_or_update" do
        service.assign_requester
        expect(service).not_to have_received(:create_or_update_zendesk_user)
      end
    end

    context "if requester is not assigned" do
      let(:intake_ticket_requester_id) { nil }

      before do
        allow(service).to receive(:create_or_update_zendesk_user) { output_ticket_requester_id }
      end

      it "updates intake ticket requester id" do
        service.assign_requester
        expect(intake.intake_ticket_requester_id).to eq(output_ticket_requester_id)
      end

      context "filters contact info by preference" do
        before do
          service.assign_requester
        end

        context "when opted in to email only" do
          let(:email_opt_in) { "yes" }
          let(:sms_opt_in) { "no" }

          it "passes the email address and not phone" do
            expect(service).to have_received(:create_or_update_zendesk_user).with(hash_including(
                                                                                    email: "cash@raining.money",
                                                                                    phone: nil,
                                                                                  ))
          end
        end

        context "when opted in to sms only" do
          let(:email_opt_in) { "no" }
          let(:sms_opt_in) { "yes" }

          it "passes the phone and not email address" do
            expect(service).to have_received(:create_or_update_zendesk_user).with hash_including(
              email: nil,
              phone: "+14155551234",
            )
          end
        end

        context "when opted in to email and sms" do
          let(:email_opt_in) { "yes" }
          let(:sms_opt_in) { "yes" }

          it "passes the phone and email address" do
            expect(service).to have_received(:create_or_update_zendesk_user).with hash_including(
              email: "cash@raining.money",
              phone: "+14155551234",
            )
          end
        end
      end

      context "sets time zone" do
        before do
          service.assign_requester
        end

        context "with valid time zone" do
          it "converts intake time zone to Zendesk time zone" do
            expect(service).to have_received(:create_or_update_zendesk_user).with hash_including(time_zone: "Central Time (US & Canada)")
          end
        end

        context "with time zone we cannot convert to a Zendesk time zone" do
          let(:timezone) { "Timbuktu Time" }

          it "converts intake time zone to Zendesk time zone" do
            expect(service).to have_received(:create_or_update_zendesk_user).with hash_including(time_zone: nil)
          end
        end

        context "with nil time zone" do
          let(:timezone) { nil }

          it "sends nil timezone to Zendesk API" do
            expect(service).to have_received(:create_or_update_zendesk_user).with hash_including(time_zone: nil)
          end
        end
      end
    end
  end
end