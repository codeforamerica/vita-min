require 'rails_helper'

describe Ctc::Questions::W2s::MiscInfoController do
  let(:w2) { create(:w2, intake: intake) }
  let(:intake) { create :ctc_intake, :claiming_eitc, client: create(:client, :with_ctc_return) }
  let(:box12a_code) { 'F' }

  before do
    sign_in intake.client
    Flipper.enable(:eitc)
  end

  describe 'next_path' do
    let(:box13_statutory_employee) { 'no' }
    let(:params) do
      {
        id: w2.id,
        ctc_w2s_misc_info_form: {
          box11_nonqualified_plans: '234',
          box12a_code: box12a_code,
          box12a_value: '324',
          box12b_code: 'E',
          box12b_value: '56',
          box12c_code: 'C',
          box12c_value: '78',
          box12d_code: 'D',
          box12d_value: '90',
          box13_statutory_employee: box13_statutory_employee,
          box13_retirement_plan: 'yes',
          box13_third_party_sick_pay: 'yes',
        }
      }
    end

    it 'continues to the W2 confirmation page' do
      put :update, params: params

      expect(response).to redirect_to(Ctc::Questions::ConfirmW2sController.to_path_helper)
    end

    context 'when they check the Statutory Employee checkbox' do
      let(:box13_statutory_employee) { 'yes' }

      it 'offboards to use_gyr' do
        put :update, params: params

        expect(response).to redirect_to(Ctc::Questions::UseGyrController.to_path_helper)
      end
    end

    context 'when they choose an invalid code for one of the 12 boxes' do
      let(:box12a_code) { 'A' }

      it 'offboards to use_gyr' do
        put :update, params: params

        expect(response).to redirect_to(Ctc::Questions::UseGyrController.to_path_helper)
      end
    end
  end
end
