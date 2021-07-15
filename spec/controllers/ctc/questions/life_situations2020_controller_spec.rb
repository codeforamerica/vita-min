require "rails_helper"

describe Ctc::Questions::LifeSituations2020Controller do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}

      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::LifeSituations2020Form
      expect(assigns(:form).intake).to be_an_instance_of Intake::CtcIntake
    end
  end

  describe "#update" do
    let(:params) do
      {
        ctc_life_situations2020_form: {
          cannot_claim_me_as_a_dependent: "no",
          member_of_the_armed_forces: "no",
        }
      }
    end

    context "when submitting the form" do
      context "when not checking 'No one can claim me as a dependent'" do
        it "updates the intake and redirects to use-gyr" do
          expect {
            post :update, params: params
          }.to change { intake.reload.cannot_claim_me_as_a_dependent }
                 .and change { intake.reload.member_of_the_armed_forces }

          expect(response).to redirect_to questions_use_gyr_path
        end
      end

      context "when checking 'No one can claim me as a dependent'" do
        before do
          params[:ctc_life_situations2020_form][:cannot_claim_me_as_a_dependent] = "yes"
        end

        # TODO: update placeholder with /filing-status when it's available
        it "updates the intake and redirects to placeholder" do
          expect {
            post :update, params: params
          }.to change { intake.reload.cannot_claim_me_as_a_dependent }
                 .and change { intake.reload.member_of_the_armed_forces }

          expect(response).to redirect_to questions_placeholder_question_path
        end
      end
    end
  end
end