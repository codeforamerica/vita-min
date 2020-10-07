require "rails_helper"

RSpec.describe Signup, type: :model do
  describe "required fields" do
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
        expect(signup.errors).to include :phone_number
        expect(signup.errors).not_to include :email_address
        expect(signup.errors[:phone_number]).to eq(["Please choose some way for us to contact you."])
      end
    end

    context "with valid fields" do
      context "with name & phone" do
        let(:signup) { Signup.new(name: "Gary Guava", phone_number: "4155551212") }

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
  end
end
