require "rails_helper"

RSpec.describe StateFile::Questions::W2Controller do
  let(:intake) { create :state_file_az_intake }
  let(:params) do
    {
      id: state_file_w2.id,
      state_file_w2: {
        employer_state_id_num: "12345",
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

  describe "#show?" do
    it "returns false" do
      expect(described_class.show?(intake)).to eq false
    end
  end

  describe "#edit" do
    render_views

    it "shows the correct w2's attributes" do
      get :edit, params: params

      expect(response.body).to include(state_file_w2.employer_state_id_num)
    end
  end

  describe "#update" do
    context "with valid params" do
      it "updates the w2 and redirects to ?" do
        expect {
          post :update, params: params
        }.not_to change(StateFileW2, :count)

        state_file_w2.reload
        expect(state_file_w2.state_file_intake).to eq intake
        expect(state_file_w2.employer_state_id_num).to eq "12345"
        expect(state_file_w2.state_wages_amount).to eq 10000
        expect(state_file_w2.state_income_tax_amount).to eq 500
        expect(state_file_w2.local_wages_and_tips_amount).to eq 40
        expect(state_file_w2.local_income_tax_amount).to eq 30
        expect(state_file_w2.locality_nm).to eq "BOOPVILLE"

        # TODO: add this
        # expect(response).to redirect_to(StateFile::Questions::W2Controller.to_path_helper(action: :index))
      end

      context "when the client got here from the review flow" do
        # can't use shared example here because it's written for the default update in QuestionsController
        it "redirects to the review page" do
          post :update, params: params.merge(return_to_review: "y")

          expect(response).to redirect_to(StateFile::Questions::AzReviewController.to_path_helper)
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
  end
end