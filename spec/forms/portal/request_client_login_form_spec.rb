require "rails_helper"

RSpec.describe Portal::RequestClientLoginForm do
  describe "#valid?" do
    let(:form) { described_class.new(params) }

    context "without any contact info" do
      let(:params){ { sms_phone_number: "", email_address: "" } }

      it "is not valid" do
        expect(form).not_to be_valid
      end
    end

    context "with a valid email" do
      let(:params){ { sms_phone_number: "", email_address: "client@example.com" } }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "with a valid phone number" do
      let(:params){ { sms_phone_number: " 510 555 1234", email_address: "" } }

      it "is valid and normalizes the phone number format" do
        expect(form).to be_valid
        expect(form.sms_phone_number).to eq "+15105551234"
      end
    end

    context "with an invalid email" do
      let(:params){ { sms_phone_number: "", email_address: "client@example" } }

      it "is not valid" do
        expect(form).not_to be_valid
        expect(form.errors).to include :email_address
      end
    end

    context "with an invalid phone number" do
      let(:params){ { sms_phone_number: "510 555 123", email_address: "" } }

      it "is not valid" do
        expect(form).not_to be_valid
        expect(form.errors).to include :sms_phone_number
      end
    end
  end
end
