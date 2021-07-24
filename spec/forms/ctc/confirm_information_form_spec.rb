require "rails_helper"

describe Ctc::ConfirmInformationForm do
  let(:intake) { create :ctc_intake, client: create(:client, tax_returns: [create(:tax_return, filing_status: filing_status)]) }
  let(:filing_status) { "single" }

  context "validations" do
    it "does not allow signature PIN to be 00000" do
      form = described_class.new(intake, {
        primary_signature_pin: "00000",
      })
      expect(form).not_to be_valid

      expect(form.errors).to include :primary_signature_pin
    end

    it "requires signature PIN to be five digits" do
      form = described_class.new(intake, {
        primary_signature_pin: "123",
      })
      expect(form).not_to be_valid
      expect(form.errors).to include :primary_signature_pin

      form = described_class.new(intake, { primary_signature_pin: "12345" })
      puts form.errors.keys
      expect(form).to be_valid
    end

    it "requires signature PIN to be numeric" do
      form = described_class.new(intake, {
        primary_signature_pin: "1a-5?",
      })
      expect(form).not_to be_valid

      expect(form.errors).to include :primary_signature_pin
    end

    context "when filing single" do
      it "does not validate spouse PIN" do
        form = described_class.new(intake, {})
        expect(form).not_to be_valid

        expect(form.errors).to include :primary_signature_pin
        expect(form.errors).not_to include :spouse_signature_pin
      end
    end

    context "when filing jointly" do
      let(:filing_status) { "married_filing_jointly" }

      it "reports errors for both PINs" do
        form = described_class.new(intake, {
            primary_signature_pin: "00000",
            spouse_signature_pin: "",
          })
        expect(form).not_to be_valid

        expect(form.errors).to include :primary_signature_pin
        expect(form.errors).to include :spouse_signature_pin
      end
    end
  end

  describe "#save" do
    it "saves the signature PIN and timestamp" do
      described_class.new(intake, {
        primary_signature_pin: "12345",
      }).save

      intake.reload
      expect(intake.primary_signature_pin).to eq "12345"
      expect(intake.primary_signature_pin_at).to be_present
    end

    context "when filing jointly" do
      let(:filing_status) { "married_filing_jointly" }
      it "saves both IP PINs" do
        described_class.new(intake, {
          primary_signature_pin: "12345",
          spouse_signature_pin: "98765",
        }).save

        intake.reload
        expect(intake.primary_signature_pin).to eq "12345"
        expect(intake.spouse_signature_pin).to eq "98765"
        expect(intake.primary_signature_pin_at).to be_present
        expect(intake.spouse_signature_pin_at).to be_present
      end
    end
  end
end