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

    context "NJ intake" do
      let(:intake) { create(:state_file_nj_intake) }
      let!(:state_file_w2) { create :state_file_w2, state_file_intake: intake, box14_ui_hc_wd: 10 }

      context "with NJ invalid state wages" do
        before do
          allow_any_instance_of(StateFileNjIntake).to receive(:state_wages_invalid?).and_return true
          
        end

        it "adds w2 index to the list of verified W2s and removes the state_wages_amount error when user opens the page" do
          expect(state_file_w2.valid?(:state_file_edit)).to eq false
          expect(intake.confirmed_w2_ids.size).to eq 0
          expect(state_file_w2.errors).to include(:state_wages_amount)
          get :edit, params: params
          state_file_w2.reload
          state_file_w2.valid?(:state_file_edit)
          expect(intake.reload.confirmed_w2_ids).to eq [state_file_w2.id]
          expect(state_file_w2.errors).not_to include(:state_wages_amount)
          expect(response.body).to have_text(I18n.t("state_file.questions.w2.edit.box16_warning_nj"))
        end
      end

      context "with NJ valid state wages" do
        before do
          allow_any_instance_of(StateFileNjIntake).to receive(:state_wages_invalid?).and_return false
        end

        it "adds w2 id to the list of verified W2s" do
          expect(intake.confirmed_w2_ids.size).to eq 0
          expect(state_file_w2.errors).not_to include(:state_wages_amount)
          get :edit, params: params
          expect(intake.reload.confirmed_w2_ids).to eq [state_file_w2.id]
          expect(state_file_w2.errors).not_to include(:state_wages_amount)
          expect(response.body).not_to have_text(I18n.t("state_file.questions.w2.edit.box16_warning_nj"))
        end
      end

    end

    context "non NJ intake" do
      StateFile::StateInformationService.active_state_codes.excluding("nj").each do |state_code|
        let(:intake) { create("state_file_#{state_code}_intake".to_sym) }
        let!(:state_file_w2) { create :state_file_w2, state_file_intake: intake, box14_ui_hc_wd: 10 }
        let(:params) do
          {
            id: state_file_w2.id,
            state_file_w2: {
              employer_state_id_num: "12345",
              box14_stpickup: 230,
              wages: 100,
              state_wages_amount: 0,
              state_income_tax_amount: 0,
              local_wages_and_tips_amount: 40,
              local_income_tax_amount: 0,
              locality_nm: "Boopville"
            }
          }
        end
  
        it "does not show an error if state wages is 0 and federal wages is nonzero" do
          get :edit, params: params
          expect(subject.state_wages_invalid?).to eq false
          expect(state_file_w2.errors).not_to include(:state_wages_amount)
        end
      end
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
        let(:intake) { create(:state_file_nj_intake) }
        let!(:state_file_w2) { create :state_file_w2, state_file_intake: intake, box14_ui_hc_wd: 10 }
        let(:params) do
          {
            id: state_file_w2.id,
            state_file_w2: {
              employer_state_id_num: "12345",
              state_wages_amount: 10000,
              state_income_tax_amount: 500,
              box14_ui_wf_swf: 23,
              box14_fli: 45,
            }
          }
        end

        it "updates NJ Box 14 fields" do
          post :update, params: params
          state_file_w2.reload
          expect(state_file_w2.box14_ui_wf_swf).to eq 23
          expect(state_file_w2.box14_ui_hc_wd).to eq nil
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

      # TEMP: remove when flipper flag goes away
      context "when the intake's w2s are not editable" do
        let(:intake) { create :state_file_nc_intake }
        let!(:state_file_w2) { create :state_file_w2, state_file_intake: intake, w2_index: 1, employer_state_id_num: "23456" }

        context "flipper flag is enabled" do
          before do
            allow(Flipper).to receive(:enabled?).and_call_original
            allow(Flipper).to receive(:enabled?).with(:nc_flip_flop).and_return(true)
          end

          it "updates the w2 information and redirects to the income review page" do
            post :update, params: params

            state_file_w2.reload
            expect(state_file_w2.employer_state_id_num).to eq "12345"
          end
        end

        context "flipper flag is disabled" do
          it "does not updates the w2 information" do
            post :update, params: params

            state_file_w2.reload
            expect(state_file_w2.employer_state_id_num).to eq "23456"
          end
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
            box14_fli: 45,
          }
        }
      end
    
      it "renders edit with validation errors for Box 14" do
        post :update, params: params
    
        expect(response).to render_template(:edit)
        expect(response.body).to include "This amount can't exceed $180.00."
      end
    end
  end
end
