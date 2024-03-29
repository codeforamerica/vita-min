require "rails_helper"

describe ApplicationHelper do
  describe "#mask" do
    context "without a character parameter" do
      it "masks all of the digits by default" do
        expect(mask("TESTTEST")).to eq '●●●●●●●●'
      end
    end

    it "masks the string with little dots except for the number of characters indicated" do
      expect(mask("TESTTEST", 5)).to eq '●●●TTEST'
    end

    it "does not break when the string is empty" do
      expect(mask("")).to eq ""
    end

    it "does not break when the param is nil" do
      expect(mask(nil)).to eq nil
    end
  end

  describe "#ctc_current_tax_year" do
    let(:fake_multitenant_service) { double(MultiTenantService) }
    before do
      allow(MultiTenantService).to receive(:new).with(:ctc).and_return(fake_multitenant_service)
      allow(fake_multitenant_service).to receive(:current_tax_year).and_return(2018)
    end

    it "returns the GetCTC current tax year" do
      expect(ctc_current_tax_year).to eq(2018)
    end
  end

  describe "#ctc_prior_tax_year" do
    let(:fake_multitenant_service) { double(MultiTenantService) }
    before do
      allow(MultiTenantService).to receive(:new).with(:ctc).and_return(fake_multitenant_service)
      allow(fake_multitenant_service).to receive(:prior_tax_year).and_return(2017)
    end

    it "returns the GetCTC prior tax year" do
      expect(ctc_prior_tax_year).to eq(2017)
    end
  end
end
