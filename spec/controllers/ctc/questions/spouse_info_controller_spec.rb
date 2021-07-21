require "rails_helper"

describe Ctc::Questions::SpouseInfoController do
  let(:intake) { create :ctc_intake }

  describe "#edit" do
    it_behaves_like :a_get_action_for_authenticated_ctc_clients_only, action: :edit

    context "as an authenticated ctc client" do
      before do
        sign_in intake.client
      end

      it "renders edit template" do
        get :edit, params: {}
        expect(response).to render_template :edit
      end
    end
  end

  describe "#update" do
    it_behaves_like :a_post_action_for_authenticated_ctc_clients_only, action: :update

    context "as an authenticated ctc client" do
      before do
        sign_in intake.client
      end

      let(:valid_params) {
        {
          spouse_first_name: "Madeline",
          spouse_middle_initial: "J",
          spouse_last_name: "Mango",
          spouse_birth_date_year: "1963",
          spouse_birth_date_month: "9",
          spouse_birth_date_day: "10",
          spouse_ssn: "111-22-8888",
          spouse_ssn_confirmation: "111-22-8888",
          spouse_tin_type: 'ssn',
          spouse_veteran: "no"
        }
      }

      context "if they chose 'none' as the SSN/ITIN option" do
        it "redirects to use_gyr" do
          put :update, params: { ctc_spouse_info_form: valid_params.merge(spouse_tin_type: "none") }
          expect(response).to redirect_to questions_use_gyr_path
        end
      end
    end
  end
end