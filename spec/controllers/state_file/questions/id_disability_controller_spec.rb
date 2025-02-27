require "rails_helper"

RSpec.describe StateFile::Questions::IdDisabilityController do
  let(:intake) { create :state_file_id_intake }
  before do
    allow(Flipper).to receive(:enabled?).and_call_original
    allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(true)
    sign_in intake
  end

  describe "#edit" do
    render_views
    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end
  end

  describe ".show?" do
    context "when single" do
      let(:intake) { create :state_file_id_intake}
      let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, taxable_amount: 25) }
      before do
        intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 61, 1, 1)
      end

      context "when feature flag is disabled" do
        before do
          allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(false)
        end

        it "does not show" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "with a 1099R but zero taxable amount" do
        let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, taxable_amount: 0) }

        it "does not show" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "with married filing separately status" do
        let(:intake) { create :state_file_id_intake, filing_status: "married_filing_separately" }

        it "does not show" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when filer is under 62" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
        end

        it "does not show" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when filer is within the age range qualifications" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 62, 1, 1)
        end

        it "shows" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "when filer is above the age requirements" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
        end

        it "does not show" do
          expect(described_class.show?(intake)).to eq false
        end
      end
    end

    context "when married filing jointly" do
      let(:intake) { create :state_file_id_intake, :mfj_filer_with_json}
      let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, taxable_amount: 25) }

      context "when both spouses are under 62" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
          intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
        end

        it "does not show" do
          expect(described_class.show?(intake)).to eq false
        end
      end

      context "when primary is 62 and spouse is under 62" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 61, 1, 1)
          intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
        end

        it "shows" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "when primary is under 62 and spouse is 62" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 60, 1, 1)
          intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 61, 1, 1)
        end

        it "shows" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "when both spouses are 65" do
        before do
          intake.primary_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
          intake.spouse_birth_date = Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1)
        end

        it "does not show" do
          expect(described_class.show?(intake)).to eq false
        end
      end
    end
  end

  describe "#update" do
    let(:primary_disabled) { "no" }
    let(:spouse_disabled) { "no" }
    let(:form_params) do
      {
        state_file_id_disability_form: {
          primary_disabled: primary_disabled,
          spouse_disabled: spouse_disabled
        }
      }
    end
    let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, taxable_amount: 25, recipient_ssn: intake.primary.ssn) }

    context "returning from review" do
      context "has over 65 year olds in household" do
        before do
          intake.update(primary_birth_date: Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1))
        end

        it "should show the Id Retirement and Pension income controller" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper(return_to_review: "y"))
        end

        context "with no eligible 1099Rs" do
          before do
            state_file1099_r.update(taxable_amount: 0)
          end

          it "goes back to the final review screen" do
            post :update, params: form_params.merge({return_to_review: "y"})
            expect(response).to redirect_to(StateFile::Questions::IdReviewController.to_path_helper)
          end
        end
      end

      context "has disability in household" do
        let(:primary_disabled) { "yes" }

        before do
          intake.update(primary_disabled: "yes")
        end

        it "should show the Id Retirement and Pension income controller" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper(return_to_review: "y"))
        end
      end

      context "does not have disability in household" do
        before do
          intake.update(primary_disabled: "no")
        end
        it "goes back to the final review screen" do
          post :update, params: form_params.merge({return_to_review: "y"})
          expect(response).to redirect_to(StateFile::Questions::IdReviewController.to_path_helper)
        end
      end
    end

    context "not returning from review (first pass)" do
      context "has over 65 year olds in household" do
        before do
          intake.update(primary_birth_date: Date.new(MultiTenantService.statefile.current_tax_year - 65, 1, 1))
        end

        it "should show the Id Retirement and Pension income controller" do
          post :update, params: form_params
          expect(response).to redirect_to(StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper)
        end
      end

      context "has disability in household" do
        let(:primary_disabled) { "yes" }

        before do
          intake.update(primary_disabled: "yes")
        end

        it "should show the Id Retirement and Pension income controller" do
          post :update, params: form_params
          expect(response).to redirect_to(StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper)
        end
      end

      context "has no disability in household" do
        it "should go to the next controller, skipping IdRetirementAndPensionIncomeController since no disability" do
          post :update, params: form_params
          expect(response).to redirect_to(StateFile::Questions::IdHealthInsurancePremiumController.to_path_helper)
        end
      end
    end
  end
end

