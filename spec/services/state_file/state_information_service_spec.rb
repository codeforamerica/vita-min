require "rails_helper"

describe StateFile::StateInformationService do
  describe ".active_state_codes" do
    it "returns the list of state codes as strings" do
      expect(described_class.active_state_codes).to match_array ["az", "nc", "ny"]
    end
  end

  describe ".calculator_class" do
    it "returns the tax calculator class" do
      expect(described_class.calculator_class("az")).to eq Efile::Az::Az140Calculator
    end
  end

  describe ".state_name" do
    it "returns the name of the state" do
      expect(described_class.state_name("az")).to eq "Arizona"
    end

    it "throws an error for an invalid state code" do
      expect do
        described_class.state_name("boop")
      end.to raise_error(InvalidStateCodeError, "Invalid state code: boop")
    end
  end

  describe ".state_code_to_name_map" do
    it "returns a map of all the state codes to state names" do
      result = {
        "az" => "Arizona",
        "nc" => "North Carolina",
        "ny" => "New York",
      }
      expect(described_class.state_code_to_name_map).to eq result
    end
  end

  describe ".tax_refund_url" do
    it "returns the refund url" do
      expect(described_class.tax_refund_url("az")).to eq 'https://aztaxes.gov/home/checkrefund'
    end
  end

  describe ".tax_payment_url" do
    it "returns the tax payment url" do
      expect(described_class.tax_payment_url("az")).to eq 'AZTaxes.gov'
    end
  end

  describe ".voucher_form_name" do
    it "returns the name of the voucher form" do
      expect(described_class.voucher_form_name("az")).to eq 'Form AZ-140V'
    end
  end

  describe ".mail_voucher_address" do
    it "returns the mail voucher address" do
      expect(described_class.mail_voucher_address("az")).to eq "Arizona Department of Revenue<br/>"\
          "PO Box 29085<br/>"\
          "Phoenix, AZ 85038-9085".html_safe
    end
  end

  describe ".voucher_path" do
    it "returns the voucher path" do
      expect(described_class.voucher_path("az")).to eq '/pdfs/AZ-140V.pdf'
    end
  end

  describe ".tax_payment_info_url" do
    it "returns the link" do
      expect(described_class.tax_payment_info_url("az")).to eq 'https://azdor.gov/making-payments-late-payments-and-filing-extensions'
    end
  end

  describe ".vita_link" do
    it "returns the link to the airtable" do
      expect(described_class.vita_link("az")).to eq 'https://airtable.com/appnKuyQXMMCPSvVw/pag0hcyC6juDxamHo/form'
    end
  end

  describe ".survey_link" do
    it "returns the survey link" do
      expect(described_class.survey_link("az")).to eq 'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey'
    end
  end

  describe ".intake_class" do
    it "returns the intake class" do
      expect(described_class.intake_class("az")).to eq StateFileAzIntake
    end
  end

  describe ".return_type" do
    it "returns the string that goes in ReturnType in the return header and StateSubmissionTyp in the state manifest" do
      expect(described_class.return_type("az")).to eq "Form140"
    end
  end

  describe ".pay_taxes_link" do
    it "returns the pay taxes link" do
      expect(described_class.pay_taxes_link("az")).to eq "https://www.aztaxes.gov/"
    end
  end

  describe ".filing_years" do
    it "returns the filing years for a state" do
      expect(described_class.filing_years("az")).to eq [2024, 2023]
    end
  end
end