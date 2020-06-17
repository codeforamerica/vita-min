require "rails_helper"

describe IntakeProgressCalculator do
  describe "::POSSIBLE_STEPS" do
    it "inserts the document flow into the question flow after document overview" do
      expect(IntakeProgressCalculator::POSSIBLE_STEPS.index(Questions::OverviewDocumentsController))
        .to eq(IntakeProgressCalculator::POSSIBLE_STEPS.index(DocumentNavigation::FLOW.first) - 1)
    end

    it "starts with the backtaxes controller" do
      expect(IntakeProgressCalculator::POSSIBLE_STEPS.first).to eq Questions::BacktaxesController
    end
  end

  describe "#get_progress" do
    let (:intake) { create :intake }
    it "returns 0 for the progress of the starting controller and intake" do
      progress = IntakeProgressCalculator.get_progress(Questions::BacktaxesController, intake)

      expect(progress).to eq 0
    end

    it "returns 100 for the progress of the final controller and intake" do
      progress = IntakeProgressCalculator.get_progress(Questions::SuccessfullySubmittedController, intake)

      expect(progress).to eq 100
    end

    it "returns the same values for the DependentsController and the Questions:HadDependentsController" do
      expect(IntakeProgressCalculator.get_progress(DependentsController, intake)).to eq IntakeProgressCalculator.get_progress(Questions::HadDependentsController, intake)
    end

    it "includes all possible future steps until you reach the question" do
      intake_survey_yes = Intake.new(demographic_questions_opt_in: :yes)
      intake_survey_no = Intake.new(demographic_questions_opt_in: :no)
      intake_survey_unfilled = Intake.new

      expect(IntakeProgressCalculator.get_progress(Questions::MailingAddressController, intake_survey_yes)).to eq IntakeProgressCalculator.get_progress(Questions::MailingAddressController, intake_survey_no)
      expect(IntakeProgressCalculator.get_progress(Questions::MailingAddressController, intake_survey_yes)).to eq IntakeProgressCalculator.get_progress(Questions::MailingAddressController, intake_survey_unfilled)
    end
  end
end
