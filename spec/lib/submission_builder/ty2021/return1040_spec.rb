require "rails_helper"

describe SubmissionBuilder::Ty2021::Return1040 do
  let(:submission) { create :efile_submission, :ctc, filing_status: "married_filing_jointly", tax_year: 2021 }

  def create_qualifying_dependents(submission)
    submission.qualifying_dependents.delete_all
    submission.intake.dependents.each do |dependent|
      EfileSubmissionDependent.create_qualifying_dependent(submission, dependent)
    end
  end

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
        create_qualifying_dependents(submission)
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

    context "schedule EIC" do
      before do
        allow(Flipper).to receive(:enabled?).with(:eitc).and_return(true)
        submission.intake.update(
          claim_eitc: "yes",
          exceeded_investment_income_limit: "no",
          primary_birth_date: 30.years.ago,
          former_foster_youth: "yes",
          primary_tin_type: "ssn",
          spouse_tin_type: "ssn"
        )
      end

      context "when there are no qualifying dependents" do
        it "is not included" do
          xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
          expect(xml.at("IRS1040ScheduleEIC")).to be_nil
        end
      end

      context "for eitc filers with qualifying dependents" do
        before do
          create(:qualifying_child, intake: submission.intake)
          create_qualifying_dependents(submission)
          submission.reload
        end

        context 'when there are W2s' do
          before do
            create :w2, intake: submission.intake
          end

          it "is included" do
            xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
            expect(xml.at("IRS1040ScheduleEIC")).not_to be_nil
          end

          context "is Spanish" do
            before do
              submission.intake.update(irs_language_preference: "spanish")
            end

            it "attaches the ScheduleLEP and creates valid XML" do
              xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
              expect(xml.at("IRS1040ScheduleLEP")).not_to be_nil
              expect(xml.at("IRS1040ScheduleEIC")).not_to be_nil
              expect(described_class.build(submission)).to be_valid
            end
          end
        end

        context 'when there are only incomplete W2s' do
          before do
            create :w2, intake: submission.intake, completed_at: nil
          end

          it "is not included" do
            xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
            expect(xml.at("IRS1040ScheduleEIC")).to be_nil
          end
        end

        context 'when there are no W2s' do
          it "is not included" do
            xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
            expect(xml.at("IRS1040ScheduleEIC")).to be_nil
          end
        end
      end
    end

    context "attaching W2s for EITC filers" do
      before do
        allow(Flipper).to receive(:enabled?).with(:eitc).and_return(true)
        submission.intake.update(
          claim_eitc: "yes",
          exceeded_investment_income_limit: "no",
          primary_birth_date: 30.years.ago,
          former_foster_youth: "yes",
          primary_tin_type: "ssn",
          spouse_tin_type: "ssn"
        )
      end

      context "when a W2 is on the intake" do
        let!(:primary_w2) { create :w2, intake: submission.intake }
        let!(:incomplete_w2) { create :w2, intake: submission.intake, completed_at: nil }

        it "attaches the completed W2" do
          xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
          expect(xml.search("IRSW2").length).to eq(1)
          expect(xml.at("IRSW2").attr("documentId")).to eq "IRSW2-#{primary_w2.id}"
        end
      end

      context "when multiple W2s are on the intake" do
        let!(:primary_w2) { create :w2, intake: submission.intake }
        let!(:spouse_w2) { create :w2, intake: submission.intake, employee: 'spouse' }

        it "attaches both W2s" do
          xml = Nokogiri::XML::Document.parse(described_class.new(submission).document.to_xml)
          expect(xml.at_xpath("//*[@documentId=\"IRSW2-#{primary_w2.id}\"]")).not_to be_nil
          expect(xml.at_xpath("//*[@documentId=\"IRSW2-#{spouse_w2.id}\"]")).not_to be_nil
        end
      end
    end
  end
end
