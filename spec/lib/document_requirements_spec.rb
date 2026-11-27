require "rails_helper"

describe DocumentRequirements do
  subject { described_class.new(intake) }

  let(:intake) do
    create :intake,
           had_wages: "yes",
           bought_marketplace_health_insurance: "yes",
           had_retirement_income: "yes",
           was_full_time_student: "yes"
  end

  describe "#required" do
    it "includes relevant document types that are needed if relevant" do
      expect(subject.required.map(&:document_type)).to match_array [
        DocumentTypes::Identity,
        DocumentTypes::SsnItin,
        DocumentTypes::Employment,
        DocumentTypes::Form1095A,
        DocumentTypes::Form1099R,
      ]
    end

    context "when the intake answers do not make a document type relevant" do
      let(:intake) { create :intake }

      it "does not include it" do
        expect(subject.required.map(&:document_type)).to match_array [DocumentTypes::Identity, DocumentTypes::SsnItin]
      end
    end
  end

  describe "#recommended" do
    it "includes relevant document types that are not needed if relevant, excluding Other" do
      expect(subject.recommended.map(&:document_type)).to eq [DocumentTypes::StudentAccountStatement]
    end
  end

  describe "RULES" do
    it "has at most one rule per document type" do
      document_types = described_class::RULES.map(&:document_type)

      expect(document_types).to eq document_types.uniq
    end
  end

  describe "#required_persons" do
    let(:filing_joint) { "yes" }
    let(:intake) do
      create :intake,
             filing_joint: filing_joint,
             primary_first_name: "Pat",
             primary_last_name: "Primary",
             spouse_first_name: "Sam",
             spouse_last_name: "Spouse"
    end
    before { create :dependent, intake: intake, first_name: "Dee", last_name: "Dependent" }

    def required_names_for(document_type)
      described_class.for_document_type(document_type).required_persons(intake).map(&:first_and_last_name)
    end

    it "includes only the people each rule is needed for" do
      expect(required_names_for(DocumentTypes::Employment)).to eq ["Pat Primary"]
      expect(required_names_for(DocumentTypes::Identity)).to eq ["Pat Primary", "Sam Spouse"]
      expect(required_names_for(DocumentTypes::SsnItin)).to eq ["Pat Primary", "Sam Spouse", "Dee Dependent"]
    end

    context "when not filing jointly" do
      let(:filing_joint) { "no" }

      it "leaves out the spouse" do
        expect(required_names_for(DocumentTypes::Identity)).to eq ["Pat Primary"]
      end
    end
  end

  describe "document types reading from the rules" do
    it "makes a document type relevant when its rule applies" do
      expect(DocumentTypes::Form1099R.relevant_to?(intake)).to eq true
      expect(DocumentTypes::Form1099R.relevant_to?(create(:intake))).to eq false
    end

    it "makes a document type needed if relevant when its rule is required" do
      expect(DocumentTypes::Form1099R.needed_if_relevant?).to eq true
      expect(DocumentTypes::StudentAccountStatement.needed_if_relevant?).to eq false
    end

    it "offers doc help when its rule offers doc help" do
      expect(DocumentTypes::InterestDividendIncome.provide_doc_help?).to eq true
      expect(DocumentTypes::Form1099G.provide_doc_help?).to eq false
    end

    it "treats document types without a rule as not relevant, not needed, and without doc help" do
      expect(DocumentTypes::Selfie.relevant_to?(intake)).to eq false
      expect(DocumentTypes::Selfie.needed_if_relevant?).to eq false
      expect(DocumentTypes::Selfie.provide_doc_help?).to eq false
    end

    it "keeps Other relevant without making it a requirement" do
      expect(DocumentTypes::Other.relevant_to?(intake)).to eq true
      expect(subject.all.map(&:document_type)).not_to include DocumentTypes::Other
    end
  end
end
