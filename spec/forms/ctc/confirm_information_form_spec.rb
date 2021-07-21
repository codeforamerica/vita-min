require "rails_helper"

describe Ctc::ConfirmInformationForm do
  let(:intake) { create :ctc_intake, client: create(:client, tax_returns: [create(:tax_return, filing_status: filing_status)]) }
  let(:filing_status) { "single" }

  context "validations" do
    it "reports errors for the primary IP PIN" do
      form = described_class.new(intake, {
        primary_ip_pin: "00000",
      })
      expect(form).not_to be_valid

      expect(form.errors).to include :primary_ip_pin
      expect(form.errors).not_to include :spouse_ip_pin
    end

    context "when filing jointly" do
      let(:filing_status) { "married_filing_jointly" }

      it "reports errors for both IP PINs" do
        form = described_class.new(intake, {
            primary_ip_pin: "00000",
            spouse_ip_pin: "",
          })
        expect(form).not_to be_valid

        expect(form.errors).to include :primary_ip_pin
        expect(form.errors).to include :spouse_ip_pin
      end
    end
  end

  describe "#save" do
    it "saves the IP PIN" do
      expect {
        described_class.new(intake, {
          primary_ip_pin: "12345",
        }).save
      }.to change(intake, :primary_ip_pin).to("12345")
    end

    context "when filing jointly" do
      let(:filing_status) { "married_filing_jointly" }
      it "saves both IP PINs" do
        expect {
          described_class.new(intake, {
            primary_ip_pin: "12345",
            spouse_ip_pin: "98765",
          }).save
        }.to change(intake, :primary_ip_pin).to("12345").and change(intake, :spouse_ip_pin).to("98765")
      end
    end
  end
end