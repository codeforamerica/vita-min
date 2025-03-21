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

    describe "#show?" do
      context "when nj gross income is zero" do
        let(:intake) { create :state_file_nj_intake }
        it "does not show" do
          allow_any_instance_of(StateFileNjIntake).to receive(:nj_gross_income).and_return(0)
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when nj gross income is less than or equal to filing threshold" do
        let(:intake) { create :state_file_nj_intake }
        it "does not show" do
          allow_any_instance_of(StateFileNjIntake).to receive(:nj_gross_income).and_return(10_000)
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when nj gross income is greater than filing threshold" do
        let(:intake) { create :state_file_nj_intake }
        it "shows" do
          allow_any_instance_of(StateFileNjIntake).to receive(:nj_gross_income).and_return(10_001)
          expect(described_class.show?(intake)).to eq true
        end
      end
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