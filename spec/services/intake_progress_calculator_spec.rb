require "rails_helper"

describe IntakeProgressCalculator do
  describe "#get_progress" do
    let(:intake) { create :intake }
    let(:controller) { OpenStruct.new(visitor_record: intake) }

    it "returns 0 for the progress of the starting controller and intake" do
      progress = IntakeProgressCalculator.get_progress(Questions::LifeSituationsController, controller)

      expect(progress).to eq 0
    end

    it "returns 100 for the progress of the final controller and intake" do
      progress = IntakeProgressCalculator.get_progress(Questions::SuccessfullySubmittedController, controller)

      expect(progress).to eq 100
    end

    it "returns the same values for the DependentsController and the Questions:HadDependentsController" do
      expect(IntakeProgressCalculator.get_progress(DependentsController, controller)).to eq IntakeProgressCalculator.get_progress(Questions::HadDependentsController, controller)
    end

    it "adjusts possible future steps based on answers" do
      ever_married_yes = Intake::GyrIntake.new(ever_married: :yes)
      ever_married_no = Intake::GyrIntake.new(ever_married: :no)
      ever_married_unfilled = Intake::GyrIntake.new
      controller_before_question = Questions::IssuedIdentityPinController

      expect(IntakeProgressCalculator.get_progress(controller_before_question, OpenStruct.new(visitor_record: ever_married_yes))).to be < IntakeProgressCalculator.get_progress(controller_before_question, OpenStruct.new(visitor_record: ever_married_no))
      expect(IntakeProgressCalculator.get_progress(controller_before_question, OpenStruct.new(visitor_record: ever_married_no))).to eq IntakeProgressCalculator.get_progress(controller_before_question, OpenStruct.new(visitor_record: ever_married_unfilled))
    end

    context "with 211intake source" do
      let(:attributes) { { source: "211intake" } }
      let(:intake) { create :intake, **attributes }

      it "does not show the progress bar when the currently viewed controller is not found in possible steps" do
        expect(IntakeProgressCalculator.get_progress(Questions::OverviewDocumentsController, controller)).to eq -1
      end
    end
  end
end
