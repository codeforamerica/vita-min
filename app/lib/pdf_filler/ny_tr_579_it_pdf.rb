module PdfFiller
  class  NyTr579ItPdf
    include PdfHelper

    def source_pdf_name
      "tr-579-it-TY2023"
    end

    def initialize(submission)
      @submission = submission

      # Most PDF fields are grabbed right off the XML
      @xml_document = SubmissionBuilder::Ty2022::States::Ny::IndividualReturn.new(submission).document
    end

    def hash_for_pdf
      answers = {
        'Taxpayers name' =>  @submission.data_source.primary.full_name,
        'Spouses name  jointly filed return only' =>  @submission.data_source.spouse.full_name,
        '1' => claimed_attr_value('FEDAGI_AMT'), #IT201 Line 19 Fed AGI
        '2' => claimed_attr_value('RFND_AMT'), #IT201 Line 78B Total Refund
        '3' => claimed_attr_value('BAL_DUE_AMT'), #IT201 Line 80 Total Owed
        '4' => claimed_attr_value('ABA_NMBR'),
        '5' => claimed_attr_value('BANK_ACCT_NMBR'),
      }

      if @submission.data_source.account_type == 'personal_checking'
        answers.merge!('Personal checking' => 'On')
      elsif @submission.data_source.account_type == 'personal_savings'
        answers.merge!('Personal savings' => 'On')
      elsif @submission.data_source.account_type == 'business_checking'
        answers.merge!('Business checking' => 'On')
      elsif @submission.data_source.account_type == 'business_savings'
        answers.merge!('Business savings' => 'On')
      end
      if @submission.data_source.primary_esigned_yes? && @submission.data_source.primary_esigned_at > 3.years.ago
        answers.merge!({
                         'Taxpayers signature' => @submission.data_source.primary.full_name,
                         'Date' => @submission.data_source.primary_esigned_at.to_date,
                         'EROs signature' => 'Code for America Labs, Inc.',
                         'Print name' => 'Code for America Labs, Inc.',
                         'Date_3' => @submission.data_source.primary_esigned_at.to_date
                       })
      end
      if @submission.data_source.spouse_esigned_yes? && @submission.data_source.spouse_esigned_at > 3.years.ago
        answers.merge!({
                         'Spouses signature jointly filed return only' => @submission.data_source.spouse.full_name,
                         'Date_2' => @submission.data_source.spouse_esigned_at.to_date
                       })
      end
      answers
    end

    private

    def claimed_attr_value(xml_field)
      @xml_document.at(xml_field)&.attribute('claimed')&.value
    end
  end
end
