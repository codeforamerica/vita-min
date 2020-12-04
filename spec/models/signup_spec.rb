# == Schema Information
#
# Table name: signups
#
#  id            :bigint           not null, primary key
#  email_address :string
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
    end
  end
end
