require "rails_helper"

RSpec.describe Portal::RequestClientLoginForm do
  describe "#valid?" do
    let(:form) { described_class.new(params) }

    context "without any contact info" do
      let(:params){ { phone_number: "", email_address: "" } }

      it "is not valid" do
        expect(form).not_to be_valid
      end
    end

    context "with a valid email" do
      let(:params){ { phone_number: "", email_address: "client@example.com" } }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    context "with a valid phone number" do
      let(:params){ { phone_number: "510 555 1234", email_address: "" } }

      it "is valid" do
        expect(form).to be_valid
      end
    end

    xcontext "with an invalid email" do
      let(:params){ { phone_number: "", email_address: "client@example" } }

      it "is not valid" do

      end
    end

    context "with an invalid phone number" do
      let(:params){ { phone_number: "510 555 123", email_address: "" } }

      it "is not valid" do
        expect(form).not_to be_valid
      end
    end
  end
end
