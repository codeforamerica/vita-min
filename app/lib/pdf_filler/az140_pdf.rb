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
        "2a" => @submission.data_source.mailing_street,
        "2c" => [@submission.data_source.phone_daytime_area_code, @submission.data_source.phone_daytime].join(' '),
        "City, Town, Post Office" => @submission.data_source.mailing_city,
        "State" => "AZ",
        "ZIP Code" => @submission.data_source.mailing_zip,
        "Filing Status" => filing_status,
        "12" => @xml_document.at('FedAdjGrossIncome')&.text,
        "14" => @xml_document.at('ModFedAdjGrossInc')&.text,
      }
      answers
    end

    private

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
