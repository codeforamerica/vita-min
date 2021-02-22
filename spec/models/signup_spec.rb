# == Schema Information
#
# Table name: signups
#
#  id            :bigint           not null, primary key
#  email_address :citext
#  name          :string
#  phone_number  :string
#  sent_followup :boolean          default(FALSE)
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

  describe ".valid_emails_with_unsent_followups" do
    context "with signups that have valid emails and invalid emails" do
      before do
        Signup.new(email_address: nil, name: "Sarah Squash").save!(validate: false)
        create_list(:signup, 2, email_address: "beatrice@example.com", name: "Beatrice Basil", sent_followup: false)
        Signup.create!(email_address: "spinach@example.com", name: "Sally Spinach", sent_followup: true)
      end

      it "returns each valid email and the client's name from signups with unsent followups" do
        expect(Signup.valid_emails_with_unsent_followups).to match_array [['beatrice@example.com', 'Beatrice Basil']]
      end
    end
  end

  describe ".send_followup_emails", active_job: true do
    let(:fake_current_time) { Time.utc(2021, 2, 11, 10, 5, 0) }
    let!(:first_signup) { create :signup, email_address: "beatrice@example.com", name: "Beatrice Basil", sent_followup: false }
    let!(:second_signup) { create :signup, email_address: "spinach@example.com", name: "Sally Spinach", sent_followup: false }
    let!(:third_signup) { create :signup, email_address: "beatrice@example.com", name: "Beatrice Basil", sent_followup: false }

    it "queues one message per valid email with a delay between them" do
      expect {
        Timecop.freeze(fake_current_time) { Signup.send_followup_emails }
      }.to have_enqueued_job.on_queue('mailers').at(fake_current_time).with(
        "SignupFollowupMailer", "followup", "deliver_now", { args: ['beatrice@example.com', 'Beatrice Basil'] }
      ).and have_enqueued_job.on_queue("mailers").at(fake_current_time + 2.seconds).with(
        "SignupFollowupMailer", "followup", "deliver_now", { args: ['spinach@example.com', 'Sally Spinach'] }
      )
    end

    it "sets sent_folowup to true for signups with enqueued jobs" do
      Signup.send_followup_emails

      expect(first_signup.reload.sent_followup).to eq true
      expect(second_signup.reload.sent_followup).to eq true
      expect(third_signup.reload.sent_followup).to eq true
    end

    context "when batch_size is passed in" do
      it "only sends those number of emails" do
        expect {
          Signup.send_followup_emails(1)
        }.to have_enqueued_job.on_queue('mailers').exactly(:once)
      end
    end

    context "when send_followup_emails is called more than once" do
      it "only sends one email to an email address with multiple signup records" do
        expect {
          Signup.send_followup_emails(1)
          Signup.send_followup_emails(1)
          Signup.send_followup_emails(1)
        }.to have_enqueued_job.on_queue('mailers').with(
          "SignupFollowupMailer", "followup", "deliver_now", { args: ['beatrice@example.com', 'Beatrice Basil'] }
        ).once
      end
    end
  end
end
