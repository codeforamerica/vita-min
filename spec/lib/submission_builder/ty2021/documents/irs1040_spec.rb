require "rails_helper"

describe SubmissionBuilder::Ty2021::Documents::Irs1040 do
  describe ".build" do
    before do
      submission.intake.update(primary_last_name: "Kòala")
      dependent = submission.intake.dependents.first
      dependent_attrs = attributes_for(:qualifying_child, ip_pin: "123456", first_name: "Keeley Elizabeth Aurora", last_name: "Kiwi-Cucumbersteiningham", birth_date: Date.new(2020, 1, 1), relationship: "daughter", ssn: "123001234")
      dependent.update(dependent_attrs)
      dependent2 = submission.intake.dependents.second
      dependent2_attrs = attributes_for(:qualifying_child, birth_date: Date.new(1975, 1, 1), relationship: "son", ssn: "123001235") # too old to be qualifying child
      dependent2.update(dependent2_attrs)
      dependent3 = submission.intake.dependents.third
      dependent3_attrs = attributes_for(:qualifying_relative, first_name: "Kelly", birth_date: Date.new(1960, 1, 1), relationship: "parent", ssn: "123001236")
      dependent3.update(dependent3_attrs)
      EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
      EfileSubmissionDependent.create_qualifying_dependent(submission, dependent2)
      EfileSubmissionDependent.create_qualifying_dependent(submission, dependent3)
      submission.reload
    end

    let(:submission) { create :efile_submission, :ctc, filing_status: "married_filing_jointly", tax_year: 2021 }

    context "when the XML is valid" do
      let(:file_double) { double }
      let(:schema_double) { double }
      let(:submission) { create :efile_submission, :ctc }

      before do
        allow(File).to receive(:open).and_return(file_double)
        allow(Nokogiri::XML).to receive(:Schema).with(file_double).and_return(schema_double)
        allow(schema_double).to receive(:validate).and_return([])
      end

      it "returns an Efile::Response object that responds to #valid? and contains no errors and provides the created Nokogiri object" do
        response = described_class.build(submission)
        expect(response).to be_an_instance_of SubmissionBuilder::Response
        expect(response).to be_valid
        expect(response.errors).to eq []
        expect(response.document).to be_an_instance_of Nokogiri::XML::Document
      end
    end

    context "when the XML is not valid against the schema" do
      let(:file_double) { double }
      let(:schema_double) { double }
      before do
        allow(File).to receive(:open).and_return(file_double)
        allow(Nokogiri::XML).to receive(:Schema).with(file_double).and_return(schema_double)
        allow(schema_double).to receive(:validate).and_return(['error', 'error'])
      end

      it "returns an Efile::Response object that responds to #valid? and includes the Schema errors" do
        response = described_class.build(submission)
        expect(response).to be_an_instance_of SubmissionBuilder::Response
        expect(response).not_to be_valid
        expect(response.errors).to eq ['error', 'error']
        expect(response.document).to be_an_instance_of Nokogiri::XML::Document
      end
    end

    context "the XML document contents" do
      let(:outstanding_ctc) { 3000 }
      let(:claimed_rrc) { 3800 }

      before do
        create(:bank_account, intake: submission.intake)
        submission.intake.update(refund_payment_method: "direct_deposit", has_crypto_income: true, was_blind: "yes", spouse_was_blind: "yes")
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:outstanding_ctc_amount).and_return(outstanding_ctc)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:claimed_recovery_rebate_credit).and_return(claimed_rrc)
        allow(submission.tax_return).to receive(:primary_age_65_or_older?).and_return(true)
        allow(submission.tax_return).to receive(:spouse_age_65_or_older?).and_return(false)
        allow(submission.tax_return).to receive(:standard_deduction).and_return(999)
      end

      it "includes required nodes on the IRS1040" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("Primary65OrOlderInd").text).to eq "X"
        expect(xml.at("Spouse65OrOlderInd")).to be_nil
        expect(xml.at("IndividualReturnFilingStatusCd").text).to eq "2" # code for marrying filing joint
        expect(xml.at("VirtualCurAcquiredDurTYInd").text).to eq "true"
        expect(xml.at("PrimaryBlindInd").text).to eq "X"
        expect(xml.at("SpouseBlindInd").text).to eq "X"
        expect(xml.at("TotalBoxesCheckedCnt").text).to eq "3" # 65+ and blind
        expect(xml.at("TotalExemptPrimaryAndSpouseCnt").text).to eq "2" # married filing joint
        dependent_nodes = xml.search("DependentDetail")
        expect(dependent_nodes.length).to eq 2
        expect(dependent_nodes[0].at("DependentFirstNm").text).to eq "Keeley Elizabeth Aur"
        expect(dependent_nodes[0].at("DependentFirstNm").text.length).to eq 20
        expect(dependent_nodes[0].at("DependentLastNm").text).to eq "Kiwi-Cucumbersteinin"
        expect(dependent_nodes[0].at("DependentFirstNm").text.length).to eq 20
        expect(dependent_nodes[0].at("IdentityProtectionPIN").text).to eq "123456"
        expect(dependent_nodes[0].at("DependentNameControlTxt").text).to eq "KIWI"
        expect(dependent_nodes[0].at("DependentSSN").text).to eq "123001234"
        expect(dependent_nodes[0].at("DependentRelationshipCd").text).to eq "DAUGHTER"
        expect(dependent_nodes[0].at("EligibleForChildTaxCreditInd").text).to eq "X"
        expect(dependent_nodes[1].at("DependentFirstNm").text).to eq "Kelly"
        expect(dependent_nodes[1].at("DependentLastNm").text).to eq "Kiwi"
        expect(dependent_nodes[1].at("DependentNameControlTxt").text).to eq "KIWI"
        expect(dependent_nodes[1].at("DependentSSN").text).to eq "123001236"
        expect(dependent_nodes[1].at("DependentRelationshipCd").text).to eq "PARENT"
        expect(dependent_nodes[1].at("EligibleForChildTaxCreditInd")).to be_nil
        expect(xml.at("ChldWhoLivedWithYouCnt").text).to eq "1"
        expect(xml.at("OtherDependentsListedCnt").text).to eq "1"
        expect(xml.at("TotalItemizedOrStandardDedAmt").text).to eq "999"
        expect(xml.at("TotDedCharitableContriAmt").text).to eq "999"
        expect(xml.at("TotalDeductionsAmt").text).to eq "999"
        expect(xml.at("TaxableIncomeAmt").text).to eq "0"

        # Line 28: remaining amount of CTC they are claiming (as determined in flow and listed on 8812 14i
        expect(xml.at("RefundableCTCOrACTCAmt").text).to eq "3000"

        expect(xml.at("RecoveryRebateCreditAmt").text).to eq "3800" # Line 30

        # Line 32, 33, 34, 35a: Line 28 + Line 30
        expect(xml.at("RefundableCreditsAmt").text).to eq "6800"
        expect(xml.at("TotalPaymentsAmt").text).to eq "6800"
        expect(xml.at("OverpaidAmt").text).to eq "6800"
        expect(xml.at("RefundAmt").text).to eq "6800"

        expect(xml.at("RoutingTransitNum").text).to eq "019456124"
        expect(xml.at("BankAccountTypeCd").text).to eq "1"
        expect(xml.at("DepositorAccountNum").text).to eq "87654321"

        expect(xml.at("RefundProductCd").text).to eq "NO FINANCIAL PRODUCT"
      end

      it "conforms to the eFileAttachments schema" do
        expect(described_class.build(submission)).to be_valid
      end
    end

    context "when client lives in Puerto Rico" do
      before do
        submission.intake.update(home_location: :puerto_rico)
      end

      it "leaves certain fields blank and puts a special attribute on standard deduction amount" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("TotalItemizedOrStandardDedAmt").text).to eq("0")
        expect(xml.at("TotalItemizedOrStandardDedAmt").attributes['modifiedStandardDeductionInd'].value).to eq('SECT 933')
        expect(xml.at("TotDedCharitableContriAmt")).to be_nil
        expect(xml.at("TotalDeductionsAmt")).to be_nil
        expect(xml.at("RecoveryRebateCreditAmt")).to be_nil
      end

      it "conforms to the eFileAttachments schema" do
        expect(described_class.build(submission)).to be_valid
      end
    end

    context "when not claiming additional rrc credit" do
      before do
        submission.intake.update(claim_owed_stimulus_money: "no")
      end

      it "sets the credit amounts to 0, and sets refund amount to outstanding CTC amount" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)

        expect(xml.at("RecoveryRebateCreditAmt").text).to eq "0"
        expect(xml.at("RefundAmt").text).to eq "3600"
      end

      it "conforms to the eFileAttachments schema" do
        expect(described_class.build(submission)).to be_valid
      end
    end

    context "when not filing jointly but spouse information exists" do
      before do
        submission.tax_return.update(filing_status: "head_of_household")
        submission.intake.update(spouse_was_blind: "yes", was_blind: "yes", primary_birth_date: Date.today - 85.years, spouse_birth_date: Date.today - 80.years)
      end

      it "does not check the spouse boxes on the return" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("Spouse65OrOlderInd")).to be_nil
        expect(xml.at("SpouseBlindInd")).to be_nil
        expect(xml.at("TotalBoxesCheckedCnt").text).to eq "2"
      end
    end

    context "when the client is claiming and qualified for EITC" do
      let(:primary_birth_date) { 30.years.ago }

      before do
        submission.intake.update(
          claim_eitc: "yes",
          exceeded_investment_income_limit: "no",
          primary_birth_date: primary_birth_date,
          former_foster_youth: "yes",
          primary_tin_type: "ssn",
          spouse_tin_type: "ssn"
        )
        create :w2, intake: submission.intake, wages_amount: 123.45, federal_income_tax_withheld: 1.25
        create :w2, intake: submission.intake, wages_amount: 100, federal_income_tax_withheld: 3
        create :w2, intake: submission.intake, wages_amount: 1210, federal_income_tax_withheld: 31, completed_at: nil
      end

      it "includes W2 and EITC specific fields" do
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("WagesSalariesAndTipsAmt").text).to eq("223")
        expect(xml.at("TotalIncomeAmt").text).to eq("223")
        expect(xml.at("AdjustedGrossIncomeAmt").text).to eq("223")
        expect(xml.at("FormW2WithheldTaxAmt").text).to eq("4")
        expect(xml.at("WithholdingTaxAmt").text).to eq("4")
        expect(xml.at("EarnedIncomeCreditAmt").text).to eq("34")
        expect(xml.at("UndSpcfdAgeStsfyRqrEICInd")).to be_nil
        expect(xml.at("RefundableCreditsAmt").text).to eq("8234")
        expect(xml.at("TotalPaymentsAmt").text).to eq("8238")
        expect(xml.at("OverpaidAmt").text).to eq("8238")
        expect(xml.at("RefundAmt").text).to eq("8238")
      end

      it "conforms to the eFileAttachments schema" do
        expect(described_class.build(submission)).to be_valid
      end
    end
  end
end
