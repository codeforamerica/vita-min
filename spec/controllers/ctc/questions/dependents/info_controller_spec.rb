require 'rails_helper'

describe Ctc::Questions::Dependents::InfoController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake, first_name: nil, last_name: nil, relationship: nil, birth_date: nil }

  before do
    sign_in intake.client
  end

  describe "#edit" do
    it "redirects paths with /new/ in the URL back to the start of the dependents flow" do
      get :edit, params: { id: :new }
      expect(response).to redirect_to(Ctc::Questions::Dependents::HadDependentsController.to_path_helper)
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:params) do
        {
          id: dependent.id,
          ctc_dependents_info_form: {
            first_name: 'Fae',
            last_name: 'Taxseason',
            suffix: 'Jr',
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

        expect(intake.dependents.last.full_name).to eq 'Fae Taxseason Jr'
      end
    end

    context "with invalid params" do
      let(:params) do
        {
          id: dependent.id
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
