require "rails_helper"

describe FilingStatusHelper do
  describe '#marital_status' do
    context "when all fields are unfilled " do
      let(:client) { create :client, intake: (create :intake) }
      it "returns nil" do
        expect(helper.marital_status(client)).to eq "<span>N/A</span>"
      end
    end

    context "when ever married is no" do
      let(:client) { create :client, intake: (create :intake, ever_married: "no") }
      let!(:tax_return) { create :tax_return, filing_status: nil, client: client }
      it "returns a span including Single" do
        expect(helper.marital_status(client)).to eq "<span>Single</span>"
      end
    end

    context "with complex marital history" do
      let(:client) { create :client, intake: (create :intake, married: "yes", divorced:"yes", divorced_year: "2014", separated: "yes", separated_year: "2020", widowed: "yes", widowed_year: "1988")}
      it "outputs the correct information" do
        expect(helper.marital_status(client)).to eq "<span>Married, Separated 2020, Divorced 2014, Widowed 1988</span>"
      end
    end
  end

  describe "#filing_status_tax_return" do
    context "with no filing status" do
      let(:tax_return) { create :tax_return, filing_status: nil }
      it "returns nil" do
        expect(helper.filing_status_tax_return(tax_return)).to eq nil
      end
    end

    context "with filing status and note" do
      let(:tax_return) { create :tax_return, year: 2020, filing_status: "head_of_household", filing_status_note: "Or maybe single?" }
      it "returns info about filing status, tax year, and note" do
        expect(helper.filing_status_tax_return(tax_return)).to include "Or maybe single?"
        expect(helper.filing_status_tax_return(tax_return)).to include "Head of household"
        expect(helper.filing_status_tax_return(tax_return)).to include "2020"
      end
    end
  end

  describe "#filing_status" do
    context "a client without tax return filing statuses" do
      let(:client) { create :client, intake: (create :intake, filing_joint: "yes") }
      let!(:tax_return) { create :tax_return, filing_status: nil, client: client }
      it "falls back to filing status on intake" do
        expect(helper.filing_status(client)).to eq("Filing jointly")
      end
    end

    context "a client with tax return filing statuses" do
      let(:client) { create :client, tax_returns: [tax_return_2019, tax_return_2020] }
      let(:tax_return_2019) { create :tax_return, year: 2019, filing_status: "head_of_household", filing_status_note: "Married early 2020, qualifying dependent born late 2019." }
      let(:tax_return_2020) { create :tax_return, year: 2020, filing_status: "married_filing_jointly" }

      it "returns formatted filing statuses with notes, if applicable" do
        result = <<-RESULT
        <ul><li><strong>Head of household</strong><span> (2019)</span><div><i>Married early 2020, qualifying dependent born late 2019.</i></div></li><li><strong>Married filing jointly</strong><span> (2020)</span></li></ul>
        RESULT

        expect(helper.filing_status(client)).to eq result.strip_heredoc.chomp
      end
    end
  end
end