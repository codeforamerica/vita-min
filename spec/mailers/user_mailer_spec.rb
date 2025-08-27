require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#assignment_email" do
    let(:assigning_user) { create :user }
    let(:assigned_user) { create :user }
    let(:tax_return) { create :gyr_tax_return }

    it_behaves_like "a mailer with an unsubscribe link" do
      let(:mail_method) { :assignment_email }
      let(:mailer_args) do
        {
          assigned_user: assigned_user,
          assigning_user: assigning_user,
          tax_return: tax_return,
          assigned_at: tax_return.updated_at
        }
      end
      let(:email_address) { assigned_user.email }
    end

    it "delivers the email with the right subject and body" do
      email = UserMailer.assignment_email(assigned_user: assigned_user,
                                          assigning_user: assigning_user,
                                          tax_return: tax_return,
                                          assigned_at: tax_return.updated_at)
      expect do
        email.deliver_now
      end.to change(ActionMailer::Base.deliveries, :count).by 1

      expect(email.subject).to eq "GetYourRefund Client ##{tax_return.client.id} Assigned to You"
      expect(email.from).to eq ["no-reply@test.localhost"]
      expect(email.to).to eq [assigned_user.email]
      expect(email.text_part.decoded.strip).to include hub_client_url(id: tax_return.client)
      expect(email.html_part.decoded).to include hub_client_url(id: tax_return.client)
    end
  end

  describe "#incoming_interaction_notification_email" do
    let(:client) { create :client }
    let(:user) { create :user }
    let(:received_at) { DateTime.now }

    context "when the interaction type is new client message" do
      it_behaves_like "a mailer with an unsubscribe link" do
        let(:mail_method) { :incoming_interaction_notification_email }
        let(:mailer_args) do
          {
            client: client,
            user: user,
            received_at: received_at,
            interaction_count: 1,
            interaction_type: "new_client_message"
          }
        end
        let(:email_address) { user.email }
      end

      it "delivers the email with the right subject and body" do
        email = UserMailer.incoming_interaction_notification_email(
          client: client,
          user: user,
          received_at: received_at,
          interaction_count: 1,
          interaction_type: "new_client_message"
        )
        expect do
          email.deliver_now
        end.to change(ActionMailer::Base.deliveries, :count).by 1

        expect(email.subject).to eq "1 New Message(s) from GetYourRefund Client ##{client.id}"
        expect(email.from).to eq ["no-reply@test.localhost"]
        expect(email.to).to eq [user.email]
        expect(email.text_part.decoded.strip).to include hub_client_url(id: client.id)
        expect(email.html_part.decoded).to include hub_client_url(id: client.id)
      end

      context "when interaction count is greater than 1" do
        it "sends the message and includes the plural subject heading" do
          email = UserMailer.incoming_interaction_notification_email(
            client: client,
            user: user,
            received_at: received_at,
            interaction_count: 3,
            interaction_type: "new_client_message"
          )
          expect do
            email.deliver_now
          end.to change(ActionMailer::Base.deliveries, :count).by 1

          expect(email.subject).to eq "3 New Message(s) from GetYourRefund Client ##{client.id}"
          expect(email.from).to eq ["no-reply@test.localhost"]
          expect(email.to).to eq [user.email]
          expect(email.text_part.decoded.strip).to include hub_client_url(id: client.id)
          expect(email.html_part.decoded).to include hub_client_url(id: client.id)
        end
      end
    end

    context "when the interaction type is document upload" do
      it_behaves_like "a mailer with an unsubscribe link" do
        let(:mail_method) { :incoming_interaction_notification_email }
        let(:mailer_args) do
          {
            client: client,
            user: user,
            received_at: received_at,
            interaction_count: 1,
            interaction_type: "document_upload"
          }
        end
        let(:email_address) { user.email }
      end

      it "delivers the email with the right subject and body" do
        email = UserMailer.incoming_interaction_notification_email(
          client: client,
          user: user,
          received_at: received_at,
          interaction_count: 1,
          interaction_type: "document_upload"
        )
        expect do
          email.deliver_now
        end.to change(ActionMailer::Base.deliveries, :count).by 1

        expect(email.subject).to eq "1 New Document(s) Uploaded by GetYourRefund Client ##{client.id}"
        expect(email.from).to eq ["no-reply@test.localhost"]
        expect(email.to).to eq [user.email]
        expect(email.text_part.decoded.strip).to include hub_client_url(id: client.id)
        expect(email.html_part.decoded).to include hub_client_url(id: client.id)
      end

      context "when interaction count is greater than 1" do
        it "sends the message and includes the plural subject heading" do
          email = UserMailer.incoming_interaction_notification_email(
            client: client,
            user: user,
            received_at: received_at,
            interaction_count: 3,
            interaction_type: "document_upload"
          )
          expect do
            email.deliver_now
          end.to change(ActionMailer::Base.deliveries, :count).by 1

          expect(email.subject).to eq "3 New Document(s) Uploaded by GetYourRefund Client ##{client.id}"
          expect(email.from).to eq ["no-reply@test.localhost"]
          expect(email.to).to eq [user.email]
          expect(email.text_part.decoded.strip).to include hub_client_url(id: client.id)
          expect(email.html_part.decoded).to include hub_client_url(id: client.id)
        end
      end
    end
  end

  describe "#internal_interaction_notification_email" do
    let(:client) { create :client }
    let(:user) { create :user }
    let(:received_at) { DateTime.now }

    context "when the interaction type is tagged in note" do
      it_behaves_like "a mailer with an unsubscribe link" do
        let(:mail_method) { :internal_interaction_notification_email }
        let(:mailer_args) do
          {
            client: client,
            user: user,
            interaction_type: "tagged_in_note",
            received_at: Time.now,
          }
        end
        let(:email_address) { user.email }
      end

      it "delivers the email with the right subject and body" do
        email = UserMailer.internal_interaction_notification_email(
          client: client,
          user: user,
          interaction_type: "tagged_in_note",
          received_at: Time.now,
        )
        expect do
          email.deliver_now
        end.to change(ActionMailer::Base.deliveries, :count).by 1

        expect(email.subject).to eq "Tagged in a note for GetYourRefund Client ##{client.id}"
        expect(email.from).to eq ["no-reply@test.localhost"]
        expect(email.to).to eq [user.email]
        expect(email.text_part.decoded.strip).to include hub_client_url(id: client.id)
        expect(email.html_part.decoded).to include hub_client_url(id: client.id)
      end
    end
  end
end
