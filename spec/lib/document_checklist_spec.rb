require "rails_helper"

describe DocumentChecklist do
  subject { described_class.new(intake) }

  let(:intake) { create :intake, had_wages: "yes", was_full_time_student: "yes" }

  def requirement_for(document_type)
    subject.requirements.all.find { |requirement| requirement.document_type == document_type }
  end

  describe "#all_required_satisfied?" do
    context "with no documents" do
      it "is false" do
        expect(subject.all_required_satisfied?).to eq false
      end
    end

    context "with an ID, an SSN/ITIN document, and employment documents" do
      before do
        create :document, intake: intake, document_type: DocumentTypes::Identity.key
        create :document, intake: intake, document_type: DocumentTypes::SsnItin.key
        create :document, intake: intake, document_type: DocumentTypes::Employment.key
      end

      it "is true" do
        expect(subject.all_required_satisfied?).to eq true
      end

      context "when a relevant required document type is missing" do
        let(:intake) { create :intake, had_wages: "yes", bought_marketplace_health_insurance: "yes" }

        it "is false" do
          expect(subject.all_required_satisfied?).to eq false
          expect(subject.missing_required.map(&:document_type)).to eq [DocumentTypes::Form1095A]
        end
      end
    end

    context "when a recommended document is missing" do
      before do
        create :document, intake: intake, document_type: DocumentTypes::Identity.key
        create :document, intake: intake, document_type: DocumentTypes::SsnItin.key
        create :document, intake: intake, document_type: DocumentTypes::Employment.key
      end

      it "does not block" do
        expect(subject.missing_recommended.map(&:document_type)).to eq [DocumentTypes::StudentAccountStatement]
        expect(subject.all_required_satisfied?).to eq true
      end
    end

    context "when a required document has been archived" do
      before do
        create :archived_document, intake: intake, document_type: DocumentTypes::Identity.key
        create :document, intake: intake, document_type: DocumentTypes::SsnItin.key
        create :document, intake: intake, document_type: DocumentTypes::Employment.key
      end

      it "is false" do
        expect(subject.missing_required.map(&:document_type)).to eq [DocumentTypes::Identity]
      end
    end
  end

  describe "#satisfied?" do
    DocumentTypes::IDENTITY_TYPES.each do |identity_type|
      it "treats #{identity_type.key} as satisfying the ID requirement" do
        create :document, intake: intake, document_type: identity_type.key

        expect(subject.satisfied?(requirement_for(DocumentTypes::Identity))).to eq true
      end
    end

    DocumentTypes::SECONDARY_IDENTITY_TYPES.each do |secondary_type|
      it "treats #{secondary_type.key} as satisfying the SSN/ITIN requirement" do
        create :document, intake: intake, document_type: secondary_type.key

        expect(subject.satisfied?(requirement_for(DocumentTypes::SsnItin))).to eq true
      end
    end

    context "when a requirement accepts more than one document type" do
      let(:intake) { create :intake, had_interest_income: "yes" }

      it "is satisfied by either document type" do
        create :document, intake: intake, document_type: DocumentTypes::Form1099Div.key

        expect(subject.satisfied?(requirement_for(DocumentTypes::Form1099Int))).to eq true
      end
    end

    it "counts documents attached to the client but not the intake" do
      create :document, intake: nil, client: intake.client, document_type: DocumentTypes::Employment.key

      expect(subject.satisfied?(requirement_for(DocumentTypes::Employment))).to eq true
    end
  end

  context "when the intake has no client yet" do
    let(:intake) { build :intake, client: nil, had_wages: "yes" }

    it "treats every requirement as missing" do
      expect(subject.missing_required.map(&:document_type)).to match_array [
        DocumentTypes::Identity,
        DocumentTypes::SsnItin,
        DocumentTypes::Employment,
      ]
    end
  end

  describe "#provided_count" do
    it "counts every document that satisfies the requirement" do
      create :document, intake: intake, document_type: DocumentTypes::PrimaryIdentification::Passport.key
      create :document, intake: intake, document_type: DocumentTypes::PrimaryIdentification::DriversLicense.key
      create :document, intake: intake, document_type: DocumentTypes::Employment.key

      expect(subject.provided_count(requirement_for(DocumentTypes::Identity))).to eq 2
    end
  end
end
