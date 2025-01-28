require "rails_helper"

RSpec.describe StateFile::Questions::NjReviewController do
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    context 'when no dependents' do
      let(:intake) { create :state_file_nj_intake, :df_data_no_deps }

      it 'does not show the dependents without health insurance block' do
        allow_any_instance_of(StateFileNjIntake).to receive(:has_health_insurance_requirement_exception?).and_return false
        get :edit
        expect(response.body).not_to have_text "Dependents who DO NOT have health insurance"
      end
    end

    context 'when taxpayer has dependents' do
      let(:intake) { create :state_file_nj_intake, :df_data_qss }
      context 'when taxpayer does not have health insurance exception' do
        it 'does not show the dependents without health insurance block' do
          allow_any_instance_of(StateFileNjIntake).to receive(:has_health_insurance_requirement_exception?).and_return false
          get :edit
          expect(response.body).not_to have_text "Dependents who DO NOT have health insurance"
        end
      end

      context 'when taxpayer does have health insurance exception' do
        it 'shows the dependents without health insurance block' do
          allow_any_instance_of(StateFileNjIntake).to receive(:has_health_insurance_requirement_exception?).and_return true
          get :edit
          expect(response.body).to have_text "Dependents who DO NOT have health insurance"
        end
      end
    end
  end
end