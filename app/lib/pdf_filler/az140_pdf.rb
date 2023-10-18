module PdfFiller
  class Az140Pdf
    include PdfHelper

    def source_pdf_name
      "az140-TY2022"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2022::States::Az::IndividualReturn.new(submission).document
    end

    def hash_for_pdf
      answers = {
        # TODO: name information doesn't seem to exist in AZ schema, just NameControl
        "1a" => [@submission.data_source.primary.first_name, @submission.data_source.primary.middle_initial].map(&:presence).compact.join(' '),
        "1b" => @submission.data_source.primary.last_name,
        "1c" => @submission.data_source.primary.ssn,
        "1d" => [@submission.data_source.spouse.first_name, @submission.data_source.spouse.middle_initial].map(&:presence).compact.join(' '),
        "1e" => @submission.data_source.spouse.last_name,
        "1f" => @submission.data_source.spouse.ssn,
        "2a" => @submission.data_source.direct_file_data.mailing_street,
        "2c" => [@submission.data_source.direct_file_data.phone_daytime_area_code, @submission.data_source.direct_file_data.phone_daytime].join(' '),
        "City, Town, Post Office" => @submission.data_source.direct_file_data.mailing_city,
        "State" => "AZ",
        "ZIP Code" => @submission.data_source.direct_file_data.mailing_zip,
        "Filing Status" => filing_status,
        "8" => calculated_fields.fetch(:AMT_8),
        "9" => calculated_fields.fetch(:AMT_9),
        "10a" => "TODO",
        "10b" => "TODO",
        "11a" => "TODO",
        "10d First" => "TODO",
        "10e First" => "TODO",
        "10d Last" => "TODO",
        "10e Last" => "TODO",
        "10d SSN" => "TODO",
        "10e SSN" => "TODO",
        "10d Relationship" => "TODO",
        "10e Relationship" => "TODO",
        "10d Mo in Home" => "TODO",
        "10e Mo in Home" => "TODO",
        "10d_10a check box" => "TODO",
        "10e_10a check box" => "TODO",
        "12" => @xml_document.at('FedAdjGrossIncome')&.text,
        "14" => @xml_document.at('ModFedAdjGrossInc')&.text,
      }
      answers
    end



    # FieldType: Button
    # FieldName: 10d_10b check box
    # FieldFlags: 0
    # FieldJustification: Left
    # FieldStateOption: Yes
    # FieldStateOption: Off
    # ---
    # FieldType: Button
    # FieldName: 10e_10b check box
    # FieldFlags: 0
    # FieldJustification: Left
    # FieldStateOption: Yes
    # FieldStateOption: Off
    # ---
    # FieldType: Button
    # FieldName: 10d educ
    # FieldFlags: 0
    # FieldJustification: Left
    # FieldStateOption: Yes
    # FieldStateOption: Off
    # ---
    # FieldType: Button
    # FieldName: 10e educ
    # FieldFlags: 0
    # FieldJustification: Left
    # FieldStateOption: Yes
    # FieldStateOption: Off
    # ---
    # FieldType: Text
    # FieldName: 11c First
    # FieldFlags: 12582912
    # FieldJustification: Left
    # ---
    # FieldType: Text
    # FieldName: 11c Last
    # FieldFlags: 12582912
    # FieldJustification: Left
    # ---
    # FieldType: Text
    # FieldName: 11c SSN
    # FieldFlags: 12582912
    # FieldJustification: Center
    # ---
    # FieldType: Text
    # FieldName: 11c Relationship
    # FieldFlags: 12582912
    # FieldJustification: Center
    # ---
    # FieldType: Button
    # FieldName: 11c died
    # FieldFlags: 0
    # FieldJustification: Left
    # FieldStateOption: Yes
    # FieldStateOption: Off
    # ---
    # FieldType: Button
    # FieldName: 11a check box
    private
    def calculated_fields
      @calculated_fields ||= @submission.data_source.tax_calculator.calculate
    end
    
    FILING_STATUS_OPTIONS = {
      "MarriedJoint" => 'Choice1',
      "HeadHousehold" => 'Choice2',
      "MarriedFilingSeparateReturn" => 'Choice3',
      "Single" => 'Choice4',
    }

    def filing_status
      FILING_STATUS_OPTIONS[@xml_document.at('FilingStatus')&.text]
    end
  end
end
