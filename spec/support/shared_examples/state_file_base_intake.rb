require "rails_helper"

shared_examples :state_file_base_intake do |factory:|
  describe "validations" do
    describe "uses a 3rd party library to validate emails" do
      context "with an invalid email" do
        it "is not valid" do
          intake = build(factory, email_address: "someone@nowhere")
          expect(intake).not_to be_valid
          expect(intake.errors).to include :email_address
        end
      end

      context "with a valid email" do
        it "is valid" do
          intake = build(factory, email_address: "someone@example.com")
          expect(intake).to be_valid
        end
      end
    end

    describe "uses a 3rd party library to validate phone numbers" do
      context "with an invalid phone number" do
        it "is not valid" do
          intake = build(factory, phone_number: "55555")
          expect(intake).not_to be_valid
          expect(intake.errors).to include :phone_number
        end
      end

      context "with a valid phone number" do
        it "is valid" do
          intake = build(factory, phone_number: "+14153334444")
          expect(intake).to be_valid
        end
      end
    end
  end

  describe "Person" do
    describe "#full_name" do
      it "returns all the names" do
        intake = build(:state_file_az_intake, primary_first_name: "Te", primary_last_name: "Sting")
        expect(intake.primary.full_name).to eq "Te Sting"
      end
    end
  end
end