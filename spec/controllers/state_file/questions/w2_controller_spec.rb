require "rails_helper"

RSpec.describe StateFile::Questions::W2Controller do
  let(:intake) { create :state_file_az_intake }
  let(:params) do
    {
      id: state_file_w2.id,
      state_file_w2: {
        employer_state_id_num: "12345",
        box14_stpickup: 230,
        state_wages_amount: 10000,
        state_income_tax_amount: 500,
        local_wages_and_tips_amount: 40,
        local_income_tax_amount: 30,
        locality_nm: "Boopville"
      }
    }
  end
  let!(:state_file_w2) { create :state_file_w2, state_file_intake: intake, w2_index: 1 }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views

    context "when state has Box 14 codes" do
      let(:intake) { create :state_file_md_intake }

      it "shows Box 14 fields" do
        get :edit, params: params

        expect(response.body).to include("Box 14")
        expect(response.body).to include("What could be in Box 14?")
      end
    end

    context "when state does not have Box 14 codes" do
      let(:intake) { create :state_file_az_intake }

      it "does not show Box 14 fields" do
        get :edit, params: params

        expect(response.body).not_to include("Box 14")
        expect(response.body).not_to include("What could be in Box 14?")
      end
    end

    context "when state includes local income boxes" do
      let(:intake) { create :state_file_md_intake }

      it "shows local income boxes" do
        get :edit, params: params

        expect(response.body).to include("Box 18")
        expect(response.body).to include("Box 19")
        expect(response.body).to include("Box 20")
      end
    end

    context "when state does not include local income boxes" do
      let(:intake) { create :state_file_az_intake }

      it "does not show local income boxes" do
        get :edit, params: params

        expect(response.body).not_to include("Box 18")
        expect(response.body).not_to include("Box 19")
        expect(response.body).not_to include("Box 20")
      end
    end

    it "shows the correct w2's attributes" do
      get :edit, params: params

      expect(response.body).to include(state_file_w2.employer_state_id_num)
    end
  end

  describe "#update" do
    context "with valid params" do
      it "updates the w2 and redirects to income review" do
        expect {
          post :update, params: params
        }.not_to change(StateFileW2, :count)

        state_file_w2.reload
        expect(state_file_w2.state_file_intake).to eq intake
        expect(state_file_w2.employer_state_id_num).to eq "12345"
        expect(state_file_w2.box14_stpickup).to eq 230
        expect(state_file_w2.state_wages_amount).to eq 10000
        expect(state_file_w2.state_income_tax_amount).to eq 500
        expect(state_file_w2.local_wages_and_tips_amount).to eq 40
        expect(state_file_w2.local_income_tax_amount).to eq 30
        expect(state_file_w2.locality_nm).to eq "BOOPVILLE"

        expect(response).to redirect_to(StateFile::Questions::IncomeReviewController.to_path_helper)
      end

      context "with MD Box 14 fields" do
        let(:intake) { create :state_file_md_intake }
        let(:params) do
          {
            id: state_file_w2.id,
            state_file_w2: {
              employer_state_id_num: "12345",
              state_wages_amount: 10000,
              state_income_tax_amount: 500,
              box14_stpickup: 230
            }
          }
        end

        it "updates MD Box 14 fields" do
          post :update, params: params
          state_file_w2.reload
          expect(state_file_w2.box14_stpickup).to eq 230
        end
      end

      context "with NJ Box 14 fields" do
        let(:intake) { create :state_file_nj_intake }
        let(:params) do
          {
            id: state_file_w2.id,
            state_file_w2: {
              employer_state_id_num: "12345",
              state_wages_amount: 10000,
              state_income_tax_amount: 500,
              box14_ui_wf_swf: 23,
              box14_ui_hc_wd: 34,
              box14_fli: 45,
            }
          }
        end

        it "updates NJ Box 14 fields" do
          post :update, params: params
          state_file_w2.reload
          expect(state_file_w2.box14_ui_wf_swf).to eq 23
          expect(state_file_w2.box14_ui_hc_wd).to eq 34
          expect(state_file_w2.box14_fli).to eq 45
        end
      end

      context "hacking" do
        let(:params_with_intake_id) do
          params.merge(
            {
              state_file_w2: params[:state_file_w2].merge(
                { state_file_intake_id: create(:state_file_az_intake).id }
              )
            }
          )
        end
        let(:params_with_extra_id) do
          super().merge({ id: 2 })
        end

        it "ignores attempts to change the intake of a w2" do
          expect {
            post :update, params: params_with_intake_id
          }.not_to change(StateFileW2, :count)
          state_file_w2.reload
          expect(state_file_w2.state_file_intake_id).to eq(intake.id)
        end

        it "throws an error" do
          expect {
            post :update, params: params_with_extra_id
          }.to raise_error(NoMethodError)
        end
      end
    end

    context "with invalid params" do
      render_views

      let(:params) do
        {
          id: state_file_w2,
          state_file_w2: {
            employer_state_id_num: "12345",
            state_wages_amount: 0,
            state_income_tax_amount: 500,
            local_wages_and_tips_amount: 20,
            local_income_tax_amount: 30,
            locality_nm: "NYC"
          }
        }
      end

      it "renders edit with validation errors" do
        post :update, params: params

        expect(response).to render_template(:edit)
        expect(response.body).to include "Cannot be greater than State wages and tips."
      end
    end

    context "with invalid Box 14 values" do
      render_views

      let(:intake) { create :state_file_nj_intake }
      let(:params) do
        {
          id: state_file_w2.id,
          state_file_w2: {
            employer_state_id_num: "12345",
            state_wages_amount: 10000,
            state_income_tax_amount: 500,
            box14_ui_wf_swf: 99999,
            box14_ui_hc_wd: 34,
            box14_fli: 45,
          }
        }
      end
    
      it "renders edit with validation errors for Box 14" do
        post :update, params: params
    
        expect(response).to render_template(:edit)
        expect(response.body).to include "This amount can't exceed $179.78."
      end
    end
  end
end
