require "rails_helper"

describe IntakeProgressCalculator do
  describe "#get_progress" do
    let (:intake) { create :intake }
    it "returns 0 for the progress of the starting controller and intake" do
      progress = IntakeProgressCalculator.get_progress(Questions::WasStudentController, intake)

      expect(progress).to eq 0
    end

    it "returns 100 for the progress of the final controller and intake" do
      progress = IntakeProgressCalculator.get_progress(Questions::AdditionalInfoController, intake)

      expect(progress).to eq 100
    end

    it "returns the same values for the DependentsController and the Questions:HadDependentsController" do
      expect(IntakeProgressCalculator.get_progress(DependentsController, intake)).to eq IntakeProgressCalculator.get_progress(Questions::HadDependentsController, intake)
    end

    it "includes all possible future steps until you reach the question" do
      ever_married_yes = Intake.new(ever_married: :yes)
      ever_married_no = Intake.new(ever_married: :no)
      ever_married_unfilled = Intake.new
      controller_before_question = Questions::IssuedIdentityPinController

      expect(IntakeProgressCalculator.get_progress(controller_before_question, ever_married_yes)).to eq IntakeProgressCalculator.get_progress(controller_before_question, ever_married_no)
      expect(IntakeProgressCalculator.get_progress(controller_before_question, ever_married_yes)).to eq IntakeProgressCalculator.get_progress(controller_before_question, ever_married_unfilled)
    end
  end
end
