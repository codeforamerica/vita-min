require "rails_helper"

describe IntakeProgressCalculator do
  describe "#get_progress" do
    let (:intake) { create :intake }
    it "returns 0 for the progress of the starting controller and intake" do
      progress = IntakeProgressCalculator.get_progress(Questions::LifeSituationsController, intake)

      expect(progress).to eq 0
    end

    it "returns 100 for the progress of the final controller and intake" do
      progress = IntakeProgressCalculator.get_progress(Questions::SuccessfullySubmittedController, intake)

      expect(progress).to eq 100
    end

    it "returns the same values for the DependentsController and the Questions:HadDependentsController" do
      expect(IntakeProgressCalculator.get_progress(DependentsController, intake)).to eq IntakeProgressCalculator.get_progress(Questions::HadDependentsController, intake)
    end
  end
end
