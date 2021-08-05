require "rails_helper"

describe Ctc::Questions::LifeSituations2020Controller do

  describe "#edit" do
    it "renders edit template and initializes form" do
      get :edit, params: {}

      expect(response).to render_template :edit
      expect(assigns(:form)).to be_an_instance_of Ctc::LifeSituations2020Form
    end
  end

  describe "#update" do
    let(:params) do
      {
        ctc_life_situations2020_form: {
          can_be_claimed_as_dependent: "yes",
        }
      }
    end

    context "when submitting the form" do
      context "when someone can claim them" do
        it "redirects to use-gyr" do
          post :update, params: params
          expect(response).to redirect_to questions_use_gyr_path
        end
      end

      context "when checking no one can claim them" do
        before do
          params[:ctc_life_situations2020_form][:can_be_claimed_as_dependent] = "no"
        end

        it "redirects to consent" do
          post :update, params: params
          redirect_to questions_legal_consent_path
        end
      end
    end
  end
end