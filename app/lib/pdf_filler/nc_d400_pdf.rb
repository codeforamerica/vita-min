module PdfFiller
  class NcD400Pdf
    include PdfHelper
    include SubmissionBuilder::FormattingMethods

    def source_pdf_name
      "ncD400-TY2024"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      builder = StateFile::StateInformationService.submission_builder_class(:nc)
      @xml_document = builder.new(submission).document
    end

    def hash_for_pdf
      mfs_spouse_first_name = @xml_document.at("MFSSpouseName FirstName")&.text || ""
      mfs_spouse_middle_initial = @xml_document.at("MFSSpouseName MiddleInitial")&.text || ""
      mfs_spouse_last_name = @xml_document.at("MFSSpouseName LastName")&.text || ""
      mfs_spouse_name = [mfs_spouse_first_name, mfs_spouse_middle_initial, mfs_spouse_last_name].reject(&:empty?).join(" ")

      answers = {
        y_d400wf_ssn1: @submission.data_source.primary.ssn,
        y_d400wf_ssn2: @submission.data_source.spouse.ssn,
        y_d400wf_fname1: @submission.data_source.primary.first_name,
        y_d400wf_mi1: @submission.data_source.primary.middle_initial,
        y_d400wf_lname1: @submission.data_source.primary.last_name_and_suffix,
        y_d400wf_fname2: @submission.data_source.spouse.first_name,
        y_d400wf_mi2: @submission.data_source.spouse.middle_initial,
        y_d400wf_lname2: @submission.data_source.spouse.last_name_and_suffix,
        y_d400wf_add: @xml_document.at('Filer USAddress AddressLine1Txt')&.text,
        'y_d400wf_apartment number': @xml_document.at('Filer USAddress AddressLine2Txt')&.text,
        y_d400wf_city: @xml_document.at('Filer USAddress CityNm')&.text,
        y_d400wf_state: @xml_document.at('Filer USAddress StateAbbreviationCd')&.text,
        y_d400wf_zip: @xml_document.at('Filer USAddress ZIPCd')&.text,
        y_d400wf_dead2: formatted_date(@xml_document.at('Secondary DateOfDeath')&.text, "%m-%d-%y"),
        y_d400wf_rs1yes: 'Yes',
        y_d400wf_v1yes: checkbox_value(@submission.data_source.primary_veteran_yes?),
        y_d400wf_v2no: checkbox_value(@submission.data_source.primary_veteran_no?),
        y_d400wf_sv1yes: checkbox_value(@submission.data_source.spouse_veteran_yes?),
        y_d400wf_sv1no: checkbox_value(@submission.data_source.spouse_veteran_no?),
        y_d400wf_rs2yes: @submission.data_source.filing_status_mfj? ? 'Yes' : 'Off',
        y_d400wf_fstat1: @submission.data_source.filing_status_single? ? 'Yes' : 'Off',
        y_d400wf_fstat2: @submission.data_source.filing_status_mfj? ? 'Yes' : 'Off',
        y_d400wf_fstat3: @submission.data_source.filing_status_mfs? ? 'Yes' : 'Off',
        y_d400wf_fstat4: @submission.data_source.filing_status_hoh? ? 'Yes' : 'Off',
        y_d400wf_fstat5: @submission.data_source.filing_status_qw? ? 'Yes' : 'Off',
        y_d400wf_sname2: mfs_spouse_name,
        y_d400wf_sssn2: @xml_document.at('MFSSpouseSSN')&.text,
        y_d400wf_dead3: @xml_document.at('QWYearSpouseDied')&.text,
        y_d400wf_li6_good: @xml_document.at('FAGI')&.text,
        y_d400wf_li8_good: @xml_document.at('FAGIPlusAdditions')&.text,
        y_d400wf_li9_good: @xml_document.at('DeductionsFromFAGI')&.text,
        y_d400wf_ncstandarddeduction: 'Yes',
        y_d400wf_li11_page1_good: @xml_document.at('NCStandardDeduction')&.text,
        y_d400wf_li10a_good: @xml_document.at('NumChildrenAllowed')&.text,
        y_d400wf_li10b_good: @xml_document.at('ChildDeduction')&.text,
        y_d400wf_li12a_pg1_good: @xml_document.at('NCAGIAddition')&.text,
        y_d400wf_li12b_pg1_good: @xml_document.at('NCAGISubtraction')&.text,
        y_d400wf_li14_pg1_good: @xml_document.at('NCAGISubtraction')&.text,
        y_d400wf_li15_pg1_good: @xml_document.at('NCIncTax')&.text,
        y_d400wf_li17_pg2_good: @xml_document.at('SubTaxCredFromIncTax')&.text,
        y_d400wf_county: @submission.data_source.residence_county_name.slice(0, 5),
        y_d400wf_dayphone: @xml_document.at('ReturnHeaderState Filer Primary USPhone')&.text,
        y_d400wf_lname2_PG2: @submission.data_source.primary.last_name_and_suffix.slice(0,11),
        'y_d400wf_Consumer Use Tax': @xml_document.at('NoUseTaxDue')&.text.present? ? 'Yes' : 'Off',
        y_d400wf_li18_pg2_good: @xml_document.at('UseTax')&.text,
        y_d400wf_li19_pg2_good: @xml_document.at('TotalNCTax')&.text,
        y_d400wf_li20a_pg2_good: @xml_document.at('IncTaxWith').text,
        y_d400wf_li20b_pg2_good: @xml_document.at('IncTaxWithSpouse').text,
        y_d400wf_li23_pg2_good: @xml_document.at('NCTaxPaid').text,
        y_d400wf_li25_pg2_good: @xml_document.at('RemainingPayment').text,
        y_d400wf_li26a_pg2_good: @xml_document.at('TaxDue')&.text,
        y_d400wf_li27_pg2_good: @xml_document.at('TotalAmountDue')&.text,
        y_d400wf_li28_pg2_good: @xml_document.at('Overpayment')&.text,
        y_d400wf_li34_pg2_good: @xml_document.at('RefundAmt')&.text,
        y_d400wf_sigdate: @submission.data_source.primary_esigned_yes? ? date_type_for_timezone(@submission.data_source.primary_esigned_at)&.to_date : "",
        y_d400wf_sigdate2: @submission.data_source.spouse_esigned_yes? ? date_type_for_timezone(@submission.data_source.spouse_esigned_at)&.to_date : ""
      }

      if Flipper.enabled?(:extension_period)
        answers[:y_d400wf_li21b_pg2_good] = @xml_document.at('PdWithExt')&.text
      end

      if Flipper.enabled?(:extension_period)
        answers["y_d400wf_Out of Country"] = checkbox_value(@xml_document.at('OutOfCountry')&.text.present?)
      end
      answers["y_d400wf_fedex1yes"] = checkbox_value(@xml_document.at('FederalExtension')&.text == "1")
      answers["y_d400wf_fedex1no"] = checkbox_value(@xml_document.at('FederalExtension')&.text == "0")
      answers
    end

    def checkbox_value(condition)
      condition ? 'Yes' : 'Off'
    end
  end
end
