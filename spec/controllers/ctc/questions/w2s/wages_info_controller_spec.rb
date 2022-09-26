require 'rails_helper'

describe Ctc::Questions::W2s::WagesInfoController do
  let(:w2) { create(:w2, intake: intake) }
  let(:intake) { create :ctc_intake, :claiming_eitc, client: create(:client, :with_return) }

  before do
    sign_in intake.client
    Flipper.enable(:eitc)
  end

  describe 'next_path' do
    let(:box8_value) { '' }
    let(:box10_value) { '' }
    let(:params) do
      {
        id: w2.id,
        ctc_w2s_wages_info_form: {
          wages_amount: 123.45,
          federal_income_tax_withheld: 222.12,
          box3_social_security_wages: 1,
          box4_social_security_tax_withheld: 2,
          box5_medicare_wages_and_tip_amount: 3,
          box6_medicare_tax_withheld: 4,
          box7_social_security_tips_amount: 5,
          box8_allocated_tips: box8_value,
          box10_dependent_care_benefits: box10_value,
        }
      }
    end

    it 'continues to the employer info page' do
      put :update, params: params

      expect(response).to redirect_to(Ctc::Questions::W2s::EmployerInfoController.to_path_helper(id: w2.id))
    end

    context 'when there is a 0 in box8_allocated_tips' do
      let(:box8_value) { '0' }

      it 'continues to the employer info page' do
        put :update, params: params

        expect(response).to redirect_to(Ctc::Questions::W2s::EmployerInfoController.to_path_helper(id: w2.id))
      end
    end

    context 'when there is a number greater than 0 in box10_dependent_care_benefits' do
      let(:box10_value) { '0' }

      it 'continues to the employer info page' do
        put :update, params: params

        expect(response).to redirect_to(Ctc::Questions::W2s::EmployerInfoController.to_path_helper(id: w2.id))
      end
    end

    context 'when there is a number greater than 0 in box8_allocated_tips' do
      let(:box8_value) { '121' }

      it 'offboards to use_gyr' do
        put :update, params: params

        expect(response).to redirect_to(Ctc::Questions::UseGyrController.to_path_helper)
      end
    end

    context 'when there is a number greater than 0 in box10_dependent_care_benefits' do
      let(:box10_value) { '212' }

      it 'offboards to use_gyr' do
        put :update, params: params

        expect(response).to redirect_to(Ctc::Questions::UseGyrController.to_path_helper)
      end
    end
  end
end
