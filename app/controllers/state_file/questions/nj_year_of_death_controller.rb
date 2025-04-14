module StateFile
  class Questions::NjYearOfDeathController < Questions::QuestionsController

    def self.show?(intake)
      intake.filing_status_qw?
    end

  end
end