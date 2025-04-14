module StateFile
  class Questions::NcQssInfoController < Questions::QuestionsController

    def self.show?(intake)
      intake.filing_status_qw?
    end

  end
end
