# == Schema Information
#
# Table name: signups
#
#  id            :bigint           not null, primary key
#  email_address :citext
#  name          :string
#  phone_number  :string
#  zip_code      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "rails_helper"

RSpec.describe Signup, type: :model do
  describe "validations" do
    context "with valid fields" do
      context "with name & phone" do
        let(:signup) { Signup.new(name: "Gary Guava", phone_number: "+14155551212") }

        it "is valid" do
          expect(signup).to be_valid
        end
      end

      context "with name & email" do
        let(:signup) { Signup.new(name: "Gary Guava", email_address: "example@example.com") }

        it "is valid" do
          expect(signup).to be_valid
        end
      end
    end

    context "with invalid fields" do
      context "invalid zipcode" do
        let(:signup) { Signup.new(name: "Gary Guava", email_address: "example@example.com", zip_code: "1234") }

        it "is not valid and adds an error to the zipcode" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :zip_code
          expect(signup.errors[:zip_code]).to eq(["Please enter a valid 5-digit zip code."])
        end
      end

      context "without any fields" do
        let(:signup) { Signup.new }

        it "requires a name" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :name
        end
      end

      context "without email or phone number fields" do
        let(:signup) { Signup.new(name: "Gary Guava") }

        it "is not valid and adds an error to the phone number" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :email_address
          expect(signup.errors).not_to include :phone_number
          expect(signup.errors[:email_address]).to eq(["Please choose some way for us to contact you."])
        end
      end

      context "with an invalid phone number" do
        let(:signup) { build(:signup, phone_number: "5123456789") }

        it "is not valid and adds an error to the phone number" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :phone_number
        end
      end

      context "with an invalid email" do
        let(:signup) { build(:signup, email_address: "someone@example .com") }

        it "is not valid and adds an error to the email" do
          expect(signup).not_to be_valid
          expect(signup.errors).to include :email_address
        end
      end
    end
  end

  describe ".valid_emails" do
    context "with signups that have valid emails and invalid emails" do
      before do
        Signup.new(email_address: nil, name: "Sarah Squash").save!(validate: false)
        create_list(:signup, 2, email_address: "sally@example.com")
        Signup.create!(email_address: "spiNacH@example.com", name: "Sally Spinach")
        Signup.create!(email_address: "sPInach@example.com", name: "Sally Spinach")
      end

      it "returns each valid email" do
        expect(Signup.valid_emails.map(&:downcase)).to eq %w[sally@example.com spinach@example.com]
      end
    end
  end

  describe ".send_followup_emails", active_job: true do
    let(:fake_current_time) { Time.utc(2021, 2, 11, 10, 5, 0) }

    before do
      allow(Signup).to receive(:valid_emails).and_return(%w[sally@example.com spinach@example.com])
    end

    it "queues one message per valid email with a delay between them" do
      expect {
        Timecop.freeze(fake_current_time) { Signup.send_followup_emails }
      }.to have_enqueued_job.on_queue('mailers').at(fake_current_time).with(
        "SignupFollowupMailer", "followup", "deliver_now", { args: ["sally@example.com"] }
      ).and have_enqueued_job.on_queue("mailers").at(fake_current_time + 2.seconds).with(
        "SignupFollowupMailer", "followup", "deliver_now", { args: ["spinach@example.com"] }
      )
    end
  end
end
