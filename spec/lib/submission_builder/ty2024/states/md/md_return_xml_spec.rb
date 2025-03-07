require 'rails_helper'

describe SubmissionBuilder::Ty2024::States::Md::MdReturnXml, required_schema: "md" do
  describe ".build" do
    let(:intake) { create(:state_file_md_intake, primary_esigned: "yes", primary_esigned_at: Time.now, primary_signature_pin: "11111" ) }
    let(:submission) { create(:efile_submission, data_source: intake.reload) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }
    let(:instance) { described_class.new(submission) }
    let(:build_response) { instance.build }
    let(:xml) { Nokogiri::XML::Document.parse(build_response.document.to_xml) }

    it "generates basic components of return" do
      expect(xml.document.root.namespaces).to include({ "xmlns:efile" => "http://www.irs.gov/efile", "xmlns" => "http://www.irs.gov/efile" })
      expect(xml.document.at('AuthenticationHeader').to_s).to include('xmlns="http://www.irs.gov/efile"')
      expect(xml.document.at('ReturnHeaderState').to_s).to include('xmlns="http://www.irs.gov/efile"')

      expect(build_response.errors).not_to be_present
    end

    context "when there is a refund with banking info" do
      let(:intake) { create(:state_file_md_refund_intake) }

      it "generates FinancialTransaction xml without RefundAmt" do
        allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:refund_or_owed_amount).and_return 500
        xml = Nokogiri::XML::Document.parse(described_class.build(submission).document.to_xml)
        expect(xml.at("FinancialTransaction")).to be_present
        expect(xml.at("RefundDirectDeposit Amount")).to be_nil
      end
    end

    context "When there are 1099gs present" do
      let(:builder_class) { StateFile::StateInformationService.submission_builder_class(:md) }
      let(:intake) { create(:state_file_md_intake) }
      let(:submission) { create(:efile_submission, data_source: intake) }
      let!(:form1099g_1) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 100) }
      let!(:form1099g_2) { create(:state_file1099_g, intake: intake, state_income_tax_withheld_amount: 200) }

      it "builds all MD1099gs from intake" do
        xml = Nokogiri::XML::Document.parse(builder_class.build(submission).document.to_xml)

        expect(xml.css("MD1099G").count).to eq 2
      end
    end

    describe "#form_has_non_zero_amounts" do
      [
        {
          prefix: "MD502_SU_",
          lines: ["MD502_SU_LINE_AB", "MD502_SU_LINE_U", "MD502_SU_LINE_V", "MD502_SU_LINE_1"]
        },
        {
          prefix: "MD502CR_",
          lines: ["MD502CR_PART_M_LINE_1", "MD502CR_PART_B_LINE_2", "MD502CR_PART_B_LINE_3", "MD502CR_PART_B_LINE_4", "MD502CR_PART_AA_LINE_2", "MD502CR_PART_AA_LINE_13", "MD502CR_PART_AA_LINE_14", "MD502CR_PART_CC_LINE_7", "MD502CR_PART_CC_LINE_8", "MD502CR_PART_CC_LINE_10"]
        }
      ].each do |form|
        context "#{form[:prefix]}" do
          context "only has zero values" do
            it "returns false" do
              calculated_lines = intake.tax_calculator.calculate
              form[:lines].each do |line|
                calculated_lines[line] = 0
              end
              if instance.form_has_non_zero_amounts(form[:prefix], calculated_lines) == true
                print form[:prefix], calculated_lines
              end
              expect(instance.form_has_non_zero_amounts(form[:prefix], calculated_lines)).to eq false

            end
          end

          context "has at least one non-zero value" do
            it "returns true" do
              calculated_lines = intake.tax_calculator.calculate
              calculated_lines[form[:lines][0]] = 100
              form[:lines][1..-1].each do |line|
                calculated_lines[line] = 0
              end
              expect(instance.form_has_non_zero_amounts(form[:prefix], calculated_lines)).to eq true
            end
          end
        end
      end
    end

    context "attached documents" do
      before do
        allow(instance).to receive(:form_has_non_zero_amounts) # allows mocking of specific arguments when the file calls with multiple combinations of args
      end

      context "when there are 1099_ints present" do
        let(:intake) { create(:state_file_md_intake, :df_data_1099_int) }

        it "generates XML with 1099_int info" do
          expect(xml.css('State1099Int').count).to eq 1
          expect(xml.at('State1099Int PayerName BusinessNameLine1Txt').text).to eq 'The payer name'
          expect(xml.at('State1099Int PayerName')['payerNameControl']).to eq 'THEP'
          expect(xml.at('State1099Int PayerEIN').text).to eq '101234567'
          expect(xml.at('State1099Int RecipientSSN').text).to eq '123456789'
          expect(xml.at('State1099Int RecipientName').text).to eq 'Mary A Lando'
          expect(xml.at('State1099Int InterestIncome').text).to eq '1.0'
          expect(xml.at('State1099Int InterestOnBondsAndTreasury').text).to eq '2.0'
          expect(xml.at('State1099Int FederalTaxWithheld').text).to eq '5.0'
          expect(xml.at('State1099Int TaxExemptInterest').text).to eq '4.0'
          expect(xml.at('State1099Int TaxExemptCUSIP').text).to eq '123456789'
        end
      end

      it "includes documents that are always attached" do
        expect(xml.document.at('ReturnDataState Form502')).to be_an_instance_of Nokogiri::XML::Element
        expect(instance.pdf_documents).to be_any { |included_documents|
          included_documents.pdf == PdfFiller::Md502Pdf
        }
        expect(instance.pdf_documents).to be_any { |included_documents|
          included_documents.pdf == PdfFiller::MdEl101Pdf
        }
      end

      context "502B" do
        context "when there are dependents" do
          let!(:dependent) { create :state_file_dependent, dob: StateFileDependent.senior_cutoff_date + 20.years, intake: intake }

          it "includes the document" do
            expect(xml.document.at('ReturnDataState Form502B')).to be_an_instance_of Nokogiri::XML::Element
          end
        end

        context "when there are no dependents" do
          it "does not include the document" do
            expect(xml.document.at('ReturnDataState Form502B')).to be_nil
          end
        end
      end

      context "502R" do
        let(:intake) { create(:state_file_md_intake) }

        context "when taxable pensions/IRAs/annuities are present" do
          before do
            intake.direct_file_data.fed_taxable_pensions = 1
          end

          it "attaches a 502R" do
            expect(xml.at("Form502R")).to be_present
            expect(instance.pdf_documents).to be_any { |included_document|
              included_document.pdf == PdfFiller::Md502RPdf
            }
          end
        end

        context "when taxable pensions/IRAs/annuities are not present" do
          before do
            intake.direct_file_data.fed_taxable_pensions = 0
          end

          it "does not attach a 502R" do
            expect(xml.at("Form502R")).not_to be_present
            expect(instance.pdf_documents).not_to be_any { |included_document|
              included_document.pdf == PdfFiller::Md502RPdf
            }
          end
        end
      end

      context "502CR" do
        context "L24 or L43 and deduction method" do
          context "Form 502 L24 has an amount and deduction method is standard" do
            before do
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "S"
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_24).and_return 50
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_43).and_return 0
            end

            it "attaches a 502CR" do
              expect(xml.at("Form502CR")).to be_present
              expect(instance.pdf_documents).to be_any { |included_documents|
                included_documents.pdf == PdfFiller::Md502CrPdf
              }
            end
          end

          context "Form 502 L24 does not have an amount but L43 does have an amount and deduction method is standard" do
            before do
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_24).and_return 0
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_43).and_return 50
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "S"
            end

            it "attaches a 502CR" do
              expect(xml.at("Form502CR")).to be_present
              expect(instance.pdf_documents).to be_any { |included_documents|
                included_documents.pdf == PdfFiller::Md502CrPdf
              }
            end
          end

          context "Form 502 neither L24 has an amount nor L43" do
            before do
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_24).and_return 0
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_43).and_return 0
            end

            it "does not attach a 502CR" do
              expect(xml.at("Form502CR")).not_to be_present
              expect(instance.pdf_documents).not_to be_any { |included_documents|
                included_documents.pdf == PdfFiller::Md502CrPdf
              }
            end
          end

          context "Form 502 has both L24 and L43 but deduction method is not standard" do
            before do
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_24).and_return 100
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_43).and_return 100
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_deduction_method).and_return "N"
            end

            it "attaches a 502CR" do
              expect(xml.at("Form502CR")).to be_present
              expect(instance.pdf_documents).to be_any { |included_documents|
                included_documents.pdf == PdfFiller::Md502CrPdf
              }
            end
          end
        end
      end

      context "502SU" do
        context "L13" do
          before do
            allow(instance).to receive(:form_has_non_zero_amounts).with("MD502_SU_", anything).and_return false
          end

          context "Form 502 L13 has an amount" do
            before do
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_13).and_return 50
            end

            it "attaches a 502SU" do
              expect(xml.at("Form502SU")).to be_present
              expect(instance.pdf_documents).to be_any { |included_documents|
                included_documents.pdf == PdfFiller::Md502SuPdf
              }
            end
          end

          context "Form 502 L13 does not have an amount" do
            before do
              allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_13).and_return 0
            end

            it "does not attach a 502SU" do
              expect(xml.at("Form502SU")).not_to be_present
              expect(instance.pdf_documents).not_to be_any { |included_documents|
                included_documents.pdf == PdfFiller::Md502SuPdf
              }
            end
          end
        end

        context "L13 is zero but form may have amounts" do
          before do
            allow_any_instance_of(Efile::Md::Md502Calculator).to receive(:calculate_line_13).and_return 0
          end

          context "502SU has non-zero amounts" do
            before do
              allow(instance).to receive(:form_has_non_zero_amounts).with("MD502_SU_", anything).and_return true
            end

            it "attaches a 502SU" do
              expect(xml.at("Form502SU")).to be_present
              expect(instance.pdf_documents).to be_any { |included_documents|
                included_documents.pdf == PdfFiller::Md502SuPdf
              }
            end
          end

          context "502SU does not have non-zero amounts" do
            before do
              allow(instance).to receive(:form_has_non_zero_amounts).with("MD502_SU_", anything).and_return false
            end

            it "does not attach a 502SU" do
              expect(xml.at("Form502SU")).not_to be_present
              expect(instance.pdf_documents).not_to be_any { |included_documents|
                included_documents.pdf == PdfFiller::Md502SuPdf
              }
            end
          end
        end
      end
    end
  end
end
