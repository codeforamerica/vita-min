require 'rails_helper'

describe SubmissionBuilder::Ty2022::States::Ny::NyReturnXml, required_schema: "ny" do
  describe '.build' do
    let(:intake) { create(:state_file_ny_intake, filing_status: filing_status) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake }

    context "when single" do
      let(:filing_status) { 'single' }

      it 'generates XML from the database models' do
        xml = described_class.build(submission).document
        expect(xml.at("tiPrime FIRST_NAME").text).to eq(intake.primary.first_name)
        expect(xml.at("tiSpouse")).to be_nil
        # Added some checks on the XML...
        expect(xml.at("composition forms IT201 TX_UNEMP_AMT").attribute('claimed').value).to eq "8500"
        expect(xml.at("composition forms IT201 A_PBEMP_AMT")).to be_nil
        expect(xml.at("composition forms IT201 HH_CR_AMT")).to be_nil
        expect(xml.at("composition forms IT201 TOT_NRFNDCR_AMT")).to be_nil
        expect(xml.at("composition forms IT201 NYC_HH_CR_AMT")).to be_nil
        expect(xml.at("composition forms IT201 ESC_CHLD_CR_AMT")).to be_nil
        expect(xml.at("composition forms IT201 RL_PROP_CR_AMT")).to be_nil
        expect(xml.at("composition forms IT201 OVR_PAID_AMT")).to be_nil
        expect(xml.at("composition forms IT201 RFND_B4_EDU_AMT")).to be_nil
        expect(xml.at("composition forms IT201 RFND_AMT")).to be_nil
        expect(xml.document.root.namespaces).to include({"xmlns:efile"=>"http://www.irs.gov/efile", "xmlns"=>"http://www.irs.gov/efile"})
        expect(xml.document.at('AuthenticationHeader').to_s).not_to include('xmlns="http://www.irs.gov/efile"')
        expect(xml.document.at('ReturnHeaderState').to_s).not_to include('xmlns="http://www.irs.gov/efile"')
        expect(xml.document.at('processBO').to_s).not_to include('xmlns="http://www.irs.gov/efile"')
      end
    end

    context "when married" do
      let(:intake) { create(:state_file_ny_intake, :mfj_with_complete_spouse) }

      it 'generates XML from the database models' do
        xml = described_class.build(submission).document
        # TODO: where do we put spouse birth date? Filling SP_DOB_DT causes an error
        # expect(xml.at("rtnHeader SP_DOB_DT").text).to eq intake.spouse.birth_date.strftime("%m%d%Y")
        expect(xml.at("tiSpouse FIRST_NAME").text).to eq(intake.spouse.first_name)
        expect(xml.at("tiSpouse MI_NAME").text).to eq(intake.spouse.middle_initial)
        expect(xml.at("tiSpouse LAST_NAME").text).to eq(intake.spouse.last_name)
        expect(xml.at("tiSpouse SP_SSN_NMBR").text).to eq(intake.spouse.ssn)
        expect(xml.at("tiSpouse SP_EMP_DESC").text).to eq(intake.direct_file_data.spouse_occupation)
      end
    end

    context "when married-filing-separately (mfs) and no spouse SSN or ITIN present" do
      # NRA (non-resident alien) case
      let(:intake) { create(:state_file_ny_intake, :mfs_incomplete_spouse) }

      it "includes COND_CODE_1_NMBR in the rtnHeader" do
        xml = described_class.build(submission).document
        expect(xml.at("rtnHeader COND_CODE_1_NMBR").attribute('claimed').value).to eq("07")
      end
    end

    context "with long employment description" do
      let(:intake) { create(:state_file_ny_intake, :mfj_with_complete_spouse) }

      it 'generates XML from the database models' do
        intake.direct_file_data.primary_occupation = "Professional Juggler and unicyclist"
        intake.direct_file_data.spouse_occupation = "Manufacturer of artisan lightbulbs"

        xml = described_class.build(submission).document
        expect(xml.at("PR_EMP_DESC").text).to eq("Professional Juggler and")
        expect(xml.at("tiSpouse SP_EMP_DESC").text).to eq("Manufacturer of artisan l")
      end
    end

    context "when claiming the federal EIC" do
      let(:intake) { create(:state_file_zeus_intake) }

      it 'includes the IT215 document and EIC dependents' do
        xml = described_class.build(submission).document
        expect(xml.at("IT215")).to be_present
        dependent_nodes = xml.search("dependent")
        eic_dependent_nodes = dependent_nodes.select { |n| n.at("DEP_FORM_ID").text == "215" }
        expect(eic_dependent_nodes.length).to eq 3
        expect(intake.tax_calculator.calculate[:IT215_LINE_16]).to be_positive # E_EITC_CR_AMT
        expect(intake.tax_calculator.calculate[:IT215_LINE_27]).to be_positive # E_NYC_EITC_CR_AMT
      end
    end

    context 'when claiming the federal EIC, but the E_EITC_CR_AMT OR E_NYC_EITC_CR_AMT are 0 or more' do
      let(:intake) { create(:state_file_zeus_intake) }
      before do
        allow_any_instance_of(Efile::Ny::It215).to receive(:calculate_line_16).and_return 10 # E_EITC_CR_AMT
        allow_any_instance_of(Efile::Ny::It215).to receive(:calculate_line_27).and_return 0 # E_NYC_EITC_CR_AMT
      end

      it 'does include the IT215 document and EIC dependents' do
        xml = described_class.build(submission).document
        expect(xml.at('IT215')).to be_present
        expect(intake.tax_calculator.calculate[:IT215_LINE_16]).to be_positive
        expect(intake.tax_calculator.calculate[:IT215_LINE_27]).to be_zero
      end
    end

    context 'when claiming the federal EIC, but both E_EITC_CR_AMT AND E_NYC_EITC_CR_AMT are 0 or less' do
      let(:intake) { create(:state_file_zeus_intake) }
      before do
        allow_any_instance_of(Efile::Ny::It215).to receive(:calculate_line_16).and_return 0 # E_EITC_CR_AMT
        allow_any_instance_of(Efile::Ny::It215).to receive(:calculate_line_27).and_return 0 # E_NYC_EITC_CR_AMT
      end

      it 'does NOT include the IT215 document and EIC dependents' do
        xml = described_class.build(submission).document
        expect(xml.at('IT215')).not_to be_present
        expect(intake.tax_calculator.calculate[:IT215_LINE_16]).to be_zero
        expect(intake.tax_calculator.calculate[:IT215_LINE_27]).to be_zero
      end
    end

    context "numbers that should be omitted if zero" do
      let(:intake) { create(:state_file_ny_intake) }

      before do
        allow_any_instance_of(Efile::Ny::It215).to receive(:calculate_line_16).and_return 0
        allow_any_instance_of(Efile::Ny::It215).to receive(:calculate_line_27).and_return 0
        allow_any_instance_of(Efile::Ny::It201).to receive(:calculate_line_63).and_return 0
        allow_any_instance_of(Efile::Ny::It201).to receive(:calculate_line_65).and_return 0
        allow_any_instance_of(Efile::Ny::It201).to receive(:calculate_line_69).and_return 0
        allow_any_instance_of(Efile::Ny::It201).to receive(:calculate_line_69a).and_return 0
      end

      it "omits the tag from the xml" do
        xml = described_class.build(submission).document
        expect(xml.at("IT215 E_EITC_CR_AMT")).to be_nil
        expect(xml.at("IT215 E_NYC_EITC_CR_AMT")).to be_nil
        expect(xml.at("IT215 IT201_LINE_63")).to be_nil
        expect(xml.at("IT215 IT201_LINE_65")).to be_nil
        expect(xml.at("IT215 IT201_LINE_69")).to be_nil
        expect(xml.at("IT215 IT201_LINE_69A")).to be_nil
      end
    end

    context "when claiming the federal CTC and ODC" do
      let(:intake) { create(:state_file_zeus_intake) }

      it 'includes the IT213 document and CTC and ODC dependents' do
        xml = described_class.build(submission).document
        expect(xml.at("IT213")).to be_present
        dependent_nodes = xml.search("dependent")
        ctc_dependent_nodes = dependent_nodes.select { |n| n.at("DEP_FORM_ID").text == "348" }
        expect(ctc_dependent_nodes.length).to eq 4
      end
    end

    context "when getting a refund to a personal checking account" do
      let(:intake) { create(:state_file_ny_intake, filing_status: filing_status, payment_or_deposit_type: "direct_deposit",  routing_number: "011234567", account_number: "123456789", account_type: 1) }
      let(:filing_status) { 'single' }

      it 'generates XML from the database models' do
        xml = described_class.build(submission).document
        expect(xml.at("rtnHeader ABA_NMBR").attribute('claimed').value).to eq(intake.routing_number)
        expect(xml.at("rtnHeader BANK_ACCT_NMBR").attribute('claimed').value).to eq(intake.account_number)
        expect(xml.at("rtnHeader ACCT_TYPE_CD").attribute('claimed').value).to eq("1")
      end
    end

    context 'Yonkers' do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }

      it 'just says no to Yonkers' do
        xml = described_class.build(submission).document
        expect(xml.at("YNK_WRK_LVNG_IND")["claimed"]).to eq("2")
      end
    end

    context "when there are more than 7 dependents" do
      let(:intake) { create(:state_file_zeus_intake) }
      let(:filing_status) { 'single' }

      it "creates an additional dependents pdf" do
        submission_builder = SubmissionBuilder::Ty2022::States::Ny::NyReturnXml.new(submission)
        additional_dependents = submission_builder.pdf_documents.select do |d|
          d.pdf == PdfFiller::It201AdditionalDependentsPdf
        end
        expect(additional_dependents.present?).to eq true
      end

      context "it-213" do
        context "when there are more than 6 dependents who qualify for the ctc" do
          before do
            intake.dependents.each_with_index do |dependent, i|
              dependent.update(dob: i.years.ago, relationship: "daughter", ctc_qualifying: true)
            end
          end

          it "fills in and attaches the it-213-att" do
            submission_builder = SubmissionBuilder::Ty2022::States::Ny::NyReturnXml.new(submission)
            additional_dependents = submission_builder.pdf_documents.select do |d|
              d.pdf == PdfFiller::Ny213AttPdf
            end
            expect(additional_dependents.present?).to eq true
          end
        end

        context "when there are not more than 6 dependents who qualify for the ctc" do
          it "does not attach the it-213-att" do
            submission_builder = SubmissionBuilder::Ty2022::States::Ny::NyReturnXml.new(submission)
            additional_dependents = submission_builder.pdf_documents.select do |d|
              d.pdf == PdfFiller::Ny213AttPdf
            end
            expect(additional_dependents).not_to be_present
          end
        end
      end
    end

    context "when mailing address is longer than 30 characters" do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }
      before do
        intake.direct_file_data.mailing_street = '211212 SUBDIVISION DR POBOX #157'
        intake.direct_file_data.mailing_apartment = ''
      end
      it 'truncates under 30 characters' do
        xml = described_class.build(submission).document
        expect(xml.at("tiPrime MAIL_LN_2_ADR").text.length).to be <= 30
        expect(xml.at("tiPrime MAIL_LN_2_ADR").text).to eq('211212 SUBDIVISION DR POBOX')
        expect(xml.at("tiPrime MAIL_LN_1_ADR").text).to eq('#157')
      end
    end

    context "when mailing address is longer than 30 characters with a key word" do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }
      before do
        intake.direct_file_data.mailing_street = '211212 SUBDIVISION DR Suite 157'
        intake.direct_file_data.mailing_apartment = ''
      end
      it 'truncates before the key word' do
        xml = described_class.build(submission).document
        expect(xml.at("tiPrime MAIL_LN_2_ADR").text.length).to be <= 30
        expect(xml.at("tiPrime MAIL_LN_2_ADR").text).to eq('211212 SUBDIVISION DR')
        expect(xml.at("tiPrime MAIL_LN_1_ADR").text).to eq('Suite 157')
      end
    end

    context "when permanent address is longer than 30 characters" do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }
      before do
        intake.permanent_street = '211212 SUBDIVISION DR POBOX #157'
      end
      it 'truncates under 30 characters' do
        xml = described_class.build(submission).document
        expect(xml.at("tiPrime PERM_LN_2_ADR").text.length).to be <= 30
        expect(xml.at("tiPrime PERM_LN_2_ADR").text).to eq('211212 SUBDIVISION DR POBOX')
        expect(xml.at("tiPrime PERM_LN_1_ADR").text).to eq('#157')
      end
    end

    context "when permanent address is longer than 30 characters with a key word" do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }
      before do
        intake.permanent_street = '211212 SUBDIVISION DR Suite 157'
      end
      it 'truncates before the key word' do
        xml = described_class.build(submission).document
        expect(xml.at("tiPrime PERM_LN_2_ADR").text.length).to be <= 30
        expect(xml.at("tiPrime PERM_LN_2_ADR").text).to eq('211212 SUBDIVISION DR')
        expect(xml.at("tiPrime PERM_LN_1_ADR").text).to eq('Suite 157')
      end
    end

    context "when permanent address is longer than 30 characters with a key word within a word" do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }
      before do
        intake.permanent_street = '1416 White Plains Road 1st Floor'
      end
      it "ignores the keyword if inside another word" do
        xml = described_class.build(submission).document
        expect(xml.at("tiPrime PERM_LN_2_ADR").text.length).to be <= 30
        expect(xml.at("tiPrime PERM_LN_2_ADR").text).to eq('1416 White Plains Road 1st')
        expect(xml.at("tiPrime PERM_LN_1_ADR").text).to eq('Floor')
      end
    end

    context "when permanent city is longer than 18 characters" do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }
      before do
        intake.permanent_city = 'Castleton on Hudson'
      end
      it 'truncates down to 18 characters' do
        xml = described_class.build(submission).document
        expect(xml.at("tiPrime PERM_CTY_ADR").text.length).to eq(18)
        expect(xml.at("tiPrime PERM_CTY_ADR").text).to eq('Castleton on Hudso')
      end
    end

    context 'when zip code is longer than 5 chars' do
      let(:filing_status) { 'single' }

      it 'truncates to 5 chars' do
        allow_any_instance_of(DirectFileData).to receive(:mailing_zip).and_return('123456789')
        xml = described_class.build(submission).document
        expect(intake.direct_file_data.mailing_zip).to eq('123456789')
        expect(intake.direct_file_data.mailing_zip.length).to eq(9)
        expect(xml.at("tiPrime MAIL_ZIP_5_ADR").text.length).to eq(5)
        expect(xml.at("tiPrime MAIL_ZIP_5_ADR").text).to eq('12345')
      end
    end

    context 'when mailing_city is longer than 18 chars' do
      let(:filing_status) { 'single' }

      it 'truncates to 18 chars' do
        allow_any_instance_of(DirectFileData).to receive(:mailing_city).and_return('Castleton on Hudson')
        xml = described_class.build(submission).document
        expect(intake.direct_file_data.mailing_city).to eq('Castleton on Hudson')
        expect(intake.direct_file_data.mailing_city.length).to eq(19)
        expect(xml.at("tiPrime MAIL_CITY_ADR").text.length).to eq(18)
        expect(xml.at("tiPrime MAIL_CITY_ADR").text).to eq('Castleton on Hudso')
      end
    end

    context "when there are less than 7 dependents" do
      let(:intake) { create(:state_file_ny_intake) }
      let(:filing_status) { 'single' }

      it "does not create an additional dependents pdf" do
        submission_builder = SubmissionBuilder::Ty2022::States::Ny::NyReturnXml.new(submission)
        additional_dependents = submission_builder.pdf_documents.select do |d|
          d.pdf == PdfFiller::It201AdditionalDependentsPdf
        end
        expect(additional_dependents.present?).to eq false
      end
    end
  end
end