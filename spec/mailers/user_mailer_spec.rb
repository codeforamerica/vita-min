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
end
