require "rails_helper"

describe IntakeProgressCalculator do
  describe "#get_progress" do
    let(:intake) { create :intake }

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

    it "adjusts possible future steps based on answers" do
      ever_married_yes = Intake.new(ever_married: :yes)
      ever_married_no = Intake.new(ever_married: :no)
      ever_married_unfilled = Intake.new
      controller_before_question = Questions::IssuedIdentityPinController

      expect(IntakeProgressCalculator.get_progress(controller_before_question, ever_married_yes)).to be < IntakeProgressCalculator.get_progress(controller_before_question, ever_married_no)
      expect(IntakeProgressCalculator.get_progress(controller_before_question, ever_married_no)).to eq IntakeProgressCalculator.get_progress(controller_before_question, ever_married_unfilled)
    end

    context "with student loan interest" do
      let(:attributes) { { paid_student_loan_interest: "yes" } }
      let(:intake) { create :intake, **attributes }

      it "returns the same values for the Documents::OverviewController and the Documents::Form1098esController" do
        expect(IntakeProgressCalculator.get_progress(Documents::OverviewController, intake)).to eq IntakeProgressCalculator.get_progress(Documents::Form1098esController, intake)
      end
    end

    context "with 211intake source" do
      let(:attributes) { { source: "211intake" } }
      let(:intake) { create :intake, **attributes }

      it "does not show the progress bar when the currently viewed controller is not found in possible steps" do
        expect(IntakeProgressCalculator.get_progress(Questions::OverviewDocumentsController, intake)).to eq -1
      end
    end

  end
end
