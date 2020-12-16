# == Schema Information
#
# Table name: system_emails
#
#  id         :bigint           not null, primary key
#  body       :string           not null
#  sent_at    :datetime         not null
#  subject    :string           not null
#  to         :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  client_id  :bigint           not null
#
require "rails_helper"

RSpec.describe SystemEmail, type: :model do
  describe "required fields" do
    context "without required fields" do
      let(:email) { SystemEmail.new }

      it "is not valid and adds an error to each field" do
        expect(email).not_to be_valid
        expect(email.errors).to include :client
        expect(email.errors).to include :to
        expect(email.errors).to include :subject
        expect(email.errors).to include :body
        expect(email.errors).to include :sent_at
      end
    end

    context "with all required fields" do
      let(:message) do
        SystemEmail.new(
            client: create(:client),
            to: "someone@example.com",
            subject: "this is a subject",
            body: "hi",
            sent_at: DateTime.now,
        )
      end

      it "is valid and does not have errors" do
        expect(message).to be_valid
        expect(message.errors).to be_blank
      end
    end
  end
end
