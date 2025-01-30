require "rails_helper"

RSpec.describe StateFile::Questions::NjMedicalExpensesController do
  let(:intake) { create :state_file_nj_intake }
  before do
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end

    it 'displays 2% of NJ Gross Income in the content' do
      allow_any_instance_of(Efile::Nj::Nj1040Calculator).to receive(:calculate_line_29).and_return 12_345
      get :edit
      expect(response.body).to have_text "$246"
    end

    describe "#update" do 
      context "when a user has medical expenses" do
        let(:form_params) {
          {
            state_file_nj_medical_expenses_form: {
              medical_expenses: 1000,
            }
          }
        }
        
        it "saves the correct value for renter" do
          post :update, params: form_params
          
          intake.reload
          expect(intake.medical_expenses).to eq 1000
        end
      end
    end
  end
end