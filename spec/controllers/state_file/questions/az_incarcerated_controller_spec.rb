require "rails_helper"

RSpec.describe StateFile::Questions::AzIncarceratedController do
  let(:intake) { create :state_file_az_intake }
  before do
    session[:state_file_intake] = intake.to_global_id
    sign_in intake
  end

  describe ".show?" do
    context "when the client has an ITIN that starts with 9 in the SSN field" do
      before do
        intake.direct_file_data.primary_ssn = "912345678"
      end
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when the client is filing mfj and has a fed_agi > 25k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 2 # mfj
        intake.direct_file_data.fed_agi = 25_001
      end
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when the client is filing hoh and has a fed_agi > 25k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 4 # hoh
        intake.direct_file_data.fed_agi = 25_001
      end
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when the client is filing single and has a fed_agi > 12.5k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_501
      end
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "when the client is filing mfs and has a fed_agi > 12.5k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 3 # mfs
        intake.direct_file_data.fed_agi = 12_501
      end
      it "returns false" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    # qw now counts as hoh
    context "when the client is filing qw and has a fed_agi > 12.5k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 5 # qw
        intake.direct_file_data.fed_agi = 12_501
      end
      it "returns false" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the client is filing mfj and has a fed_agi <= 25k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 2 # mfj
        intake.direct_file_data.fed_agi = 25_000
      end
      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the client is filing hoh and has a fed_agi <= 25k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 4 # hoh
        intake.direct_file_data.fed_agi = 25_000
      end
      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the client is filing single and has a fed_agi <= 12.5k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 1 # single
        intake.direct_file_data.fed_agi = 12_500
      end
      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the client is filing mfs and has a fed_agi <= 12.5k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 3 # mfs
        intake.direct_file_data.fed_agi = 12_500
      end
      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end

    context "when the client is filing qw and has a fed_agi <= 12.5k" do
      before do
        intake.direct_file_data.primary_ssn = "123456789"
        intake.direct_file_data.filing_status = 5 # qw
        intake.direct_file_data.fed_agi = 12_500
      end
      it "returns true" do
        expect(described_class.show?(intake)).to eq true
      end
    end
  end

  describe "#update" do
    # use the return_to_review_concern shared example if the page
    # should skip to the review page when the return_to_review param is present
    # requires form_params to be set with any other required params
    it_behaves_like :return_to_review_concern do
      let(:form_params) do
        {
          us_state: "az",
          state_file_az_incarcerated_form: {
            was_incarcerated: "yes",
          }
        }
      end
    end
  end
end