require 'rails_helper'

describe Ctc::Questions::Dependents::InfoController do
  let(:intake) { create :ctc_intake }

  before do
    sign_in intake.client
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          id: :new,
          ctc_dependents_info_form: {
            first_name: 'Fae',
            last_name: 'Taxseason',
            birth_date_day: 1,
            birth_date_month: 1,
            birth_date_year: 1.year.ago.year,
            relationship: "daughter",
            full_time_student: "no",
            permanently_totally_disabled: "no"
          }
        }
      end

      it "creates a dependent and moves to the next page" do
        post :update, params: params

        expect(intake.dependents.last.full_name).to eq 'Fae Taxseason'
      end
    end

    context "for an existing record" do
      let(:dependent) { create :dependent, intake: intake, birth_date: 2.years.ago, relationship: 'daughter' }

      context "with valid params" do
        let(:params) do
          {
            id: dependent.id,
            ctc_dependents_info_form: {
              first_name: 'Fae',
              last_name: 'Taxseason',
              birth_date_day: 1,
              birth_date_month: 1,
              birth_date_year: 2.years.ago.year,
              relationship: "daughter",
              full_time_student: "no",
              permanently_totally_disabled: "no"
            }
          }
        end

        it "updates the dependent and moves to the next page" do
          post :update, params: params

          expect(dependent.reload.full_name).to eq 'Fae Taxseason'
        end
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          id: :new
        }
      end

      it "re-renders the form with errors" do
        post :update, params: params
        expect(response).to render_template :edit
        expect(assigns(:form).errors.keys).to include(:first_name)
      end
    end
  end
end
