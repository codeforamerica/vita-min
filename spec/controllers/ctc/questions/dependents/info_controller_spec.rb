require 'rails_helper'

describe Ctc::Questions::Dependents::InfoController do
  let(:intake) { create :ctc_intake }
  let(:message_verifier) { ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base) }

  before do
    sign_in intake.client
    allow(controller).to receive(:verify_recaptcha).and_return(true)
    allow(controller).to receive(:recaptcha_reply).and_return({ 'score' => "0.9" })
  end

  describe "#edit" do
    let(:unsigned_token) { SecureRandom.base36(24) }
    let(:signed_token) { message_verifier.generate(unsigned_token) }
    let!(:dependent) { create :dependent, intake: intake, birth_date: 2.years.ago, relationship: 'daughter', creation_token: unsigned_token }

    it "can access a record by its signed creation_token" do
      get :edit, params: { id: signed_token }
      expect(assigns(:dependent)).to eq(dependent)
    end
  end

  describe "#update" do
    context "with a signed creation token for id" do
      let(:unsigned_token) { SecureRandom.base36(24) }
      let(:signed_token) { message_verifier.generate(unsigned_token) }
      let(:params) do
        {
          id: signed_token,
          ctc_dependents_info_form: {
            first_name: 'Fae',
            last_name: 'Taxseason',
            suffix: 'Jr',
            birth_date_day: 1,
            birth_date_month: 1,
            birth_date_year: 1.year.ago.year,
            relationship: "daughter",
            ssn: "222-33-4445",
            filed_joint_return: "no",
            ssn_confirmation: "222-33-4445",
            tin_type: "ssn",
          }
        }
      end

      it "creates a dependent and moves to the next page" do
        post :update, params: params

        new_dependent = intake.dependents.last
        expect(new_dependent.creation_token).to eq(unsigned_token)
        expect(new_dependent.full_name).to eq 'Fae Taxseason Jr'
        recaptcha_score = intake.client.recaptcha_scores.last
        expect(recaptcha_score.score).to eq 0.9
        expect(recaptcha_score.action).to eq 'dependents_info'
      end
    end

    context "for an existing record" do
      let(:dependent) { create :dependent, intake: intake, birth_date: 2.years.ago, relationship: 'daughter' }
      let(:birth_year) { 2.years.ago.year }
      let(:filed_joint_return) { "no" }
      context "with valid params" do
        let(:params) do
          {
            id: dependent.id,
            ctc_dependents_info_form: {
              first_name: 'Fae',
              last_name: 'Taxseason',
              birth_date_day: 1,
              birth_date_month: 1,
              birth_date_year: birth_year,
              relationship: "daughter",
              ssn: "222-33-4445",
              ssn_confirmation: "222-33-4445",
              tin_type: "ssn",
              filed_joint_return: filed_joint_return
            }
          }
        end

        it "updates the dependent and moves to the next page" do
          post :update, params: params

          expect(dependent.reload.full_name).to eq 'Fae Taxseason'
          recaptcha_score = intake.client.recaptcha_scores.last # do we want to capture the recaptcha score again for editing a dependent?
          expect(recaptcha_score.score).to eq 0.9
          expect(recaptcha_score.action).to eq 'dependents_info'
          expect(response).to redirect_to child_expenses_questions_dependent_path(id: params[:id])
        end

        context "when dependent was born after the tax year" do
          let(:birth_year) { TaxReturn.current_tax_year + 1 } # Filing year is 2021, children born in 2022 don't qualify
          it "sends the client to the offboarding page" do
            post :update, params: params
            expect(response).to redirect_to does_not_qualify_ctc_questions_dependent_path(id: params[:id])
          end
        end

        context "when dependent filed jointly with spouse" do
          let(:filed_joint_return) { "yes" }
          it "sends the client to the offboarding page" do
            post :update, params: params
            expect(response).to redirect_to does_not_qualify_ctc_questions_dependent_path(id: params[:id])
          end
        end
      end
    end

    context "with invalid params" do
      let(:signed_token) { message_verifier.generate(SecureRandom.base36(24)) }
      let(:params) do
        {
          id: signed_token
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors.attribute_names).to include(:first_name)
      end
    end
  end
end
