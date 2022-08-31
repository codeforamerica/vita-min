require "rails_helper"

describe SubmissionBuilder::Ty2021::Return1040 do
  let(:submission) { create :efile_submission, :ctc, filing_status: "married_filing_jointly", tax_year: 2021 }

  before do
    submission.intake.update(
        primary_first_name: "Hubert Blaine ",
        primary_last_name: "Wolfeschlegelsteinhausenbergerdorff ",
        spouse_first_name: "Lisa",
        spouse_last_name: "Frank",
        primary_signature_pin: "12345",
        spouse_signature_pin: "54321",
        primary_signature_pin_at: DateTime.new(2021, 4, 20, 16, 20),
        spouse_signature_pin_at: DateTime.new(2021, 4, 20, 16, 20),
        advance_ctc_amount_received: 0
    )
  end

  describe ".build" do
    it "conforms to the Return1040 schema" do
      expect(described_class.build(submission)).to be_valid
    end
  end

  describe ".document" do
    context "when the filer is filing for CTC payment" do
      before do
        create(:qualifying_child, intake: submission.intake)
        submission.create_qualifying_dependents
        submission.reload
      end

      it "attaches the 8812 document" do
         xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
         expect(xml.at("IRS1040Schedule8812")).not_to be_nil
      end
    end

    context "when the filer is not filing for CTC payment" do
      it "does not attach the 8812 document" do
        xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
        expect(xml.at("IRS1040Schedule8812")).to be_nil
      end
    end

    context "when the filer has a new language preference" do
      context "when it is English" do
        before do
          submission.intake.update(irs_language_preference: "english")
        end

        it "does not attach the ScheduleLEP" do
          xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
          expect(xml.at("IRS1040ScheduleLEP")).to be_nil
        end
      end

      context "when it is not English" do
        before do
          submission.intake.update(irs_language_preference: "spanish")
        end

        it "attaches the ScheduleLEP and creates valid XML" do
          xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
          expect(xml.at("IRS1040ScheduleLEP")).not_to be_nil
          expect(described_class.build(submission)).to be_valid
        end
      end
    end

    context "when the filer does not have a language preference" do
      before do
        submission.intake.update(irs_language_preference: nil)
      end

      it "does not attach the ScheduleLEP" do
        xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
        expect(xml.at("IRS1040ScheduleLEP")).to be_nil
      end
    end

    context "attaching W2s for EITC filers" do
      before do
        allow(Flipper).to receive(:enabled?).with(:eitc).and_return(true)
        allow(submission).to receive(:benefits_eligibility).and_return(instance_double(Efile::BenefitsEligibility, claiming_and_qualified_for_eitc?: true, outstanding_ctc_amount: 1))
      end

      context "when a W2 is on the intake" do
        let!(:primary_w2) { create :w2, intake: submission.intake }

        it "attaches the W2" do
          xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
          expect(xml.at("IRSW2")).not_to be_nil
        end
      end

      context "when multiple W2s are on the intake" do
        let!(:primary_w2) { create :w2, intake: submission.intake }
        let!(:spouse_w2) { create :w2, intake: submission.intake, legal_first_name: submission.intake.spouse_first_name }

        it "attaches both W2s" do
          xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
          expect(xml.at("IRSW2")).not_to be_nil
        end
      end
    end
  end
end