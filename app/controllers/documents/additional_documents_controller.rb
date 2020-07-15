module Documents
  class AdditionalDocumentsController < DocumentUploadQuestionController

    DocType = Struct.new(:doctype, :key)

    DOC_HELP_MAPPING = [
        []
    ]

    def self.document_type
      "Other"
    end

    def likely(intake)
      thing = [
          [intake.had_interest_income_yes?, DocType.new('1099-DIV', 'thing.stuff.key') ]
      ]

      thing.filter { |t| t.first }
    end
  end
end
