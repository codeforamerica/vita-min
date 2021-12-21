require "rails_helper"

RSpec.describe Hub::ClientForm do
  context "validations" do
    let(:form_attributes) { {} }
    let(:form) { described_class.new(form_attributes)}
    describe "#primary_first_name" do
      before do
        form_attributes[:primary_first_name] = nil
        form.valid?
      end

      it "applies a form error" do
        expect(form.errors[:primary_first_name]).to eq ["Please enter your first name."]
      end
    end

    describe "#primary_last_name" do
      before do
        form_attributes[:primary_last_name] = nil
        form.valid?
      end

      it "applies a form error" do
        expect(form.errors[:primary_last_name]).to eq ["Please enter your last name."]
      end
    end

    describe "#phone_number" do
      context "when blank" do
        before do
          form_attributes[:phone_number] = nil
          form.valid?
        end

        it "does not apply an error" do
          expect(form.errors[:phone_number]).to be_blank
        end
      end

      context "when provided and invalid" do
        before do
          form_attributes[:phone_number] = "1"
          form.valid?
        end

        it "must be a valid phone number" do
          expect(form.errors[:phone_number]).to eq ["Please enter a valid phone number."]
        end
      end

      context "when provided and valid" do
        before do
          form_attributes[:phone_number] = "8324658840"
          form.valid?
        end

        it "does not apply an error to the field" do
          expect(form.errors[:phone_number]).to be_blank
        end

        it "formats the phone number" do
          expect(form.phone_number).to eq "+18324658840"
        end
      end
    end

    describe "#sms_phone_number" do
      context "when not sms opted in" do
        before do
          form_attributes[:sms_phone_number] = nil
          form_attributes[:sms_notification_opt_in] = "no"
          form.valid?
        end

        it "is valid" do
          expect(form.errors[:sms_phone_number]).to be_blank
        end
      end

      context "when opted in to sms notifications" do
        before do
          form_attributes[:sms_notification_opt_in] = "yes"
        end

        context "when a valid number" do
          before do
            form_attributes[:sms_phone_number] = "8324658840"
            form.valid?
          end

          it "is valid" do
            expect(form.errors[:sms_phone_number]).to be_blank
          end

          it "formats the phone number" do
            expect(form.sms_phone_number).to eq "+18324658840"
          end
        end

        context "when an invalid number" do
          before do
            form_attributes[:sms_phone_number] = "1"
            form.valid?
          end

          it "is valid" do
            expect(form.errors[:sms_phone_number]).to eq ["Please enter a valid phone number."]
          end

          it "leaves the phone number bare for editing" do
            expect(form.sms_phone_number).to eq "1"
          end
        end
      end
    end

    describe "#email_address" do
      context "when not provided" do
        before do
          form_attributes[:email_address] = nil
          form.valid?
        end

        it "does not add an email error" do
          expect(form.errors).not_to include(:email_address)
        end
      end

      context "when not a valid email address" do
        before do
          form_attributes[:email_address] = "not_valid!!"
          form.valid?
        end

        it "adds an error to the attribute" do
          expect(form.errors[:email_address]).to eq ["Please enter a valid email address."]
        end
      end
    end
  end
end
