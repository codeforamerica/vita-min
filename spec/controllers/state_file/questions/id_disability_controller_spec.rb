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

    let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, taxable_amount: 25) }
    let(:between_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 63), 1, 1) }
    let(:not_between_dob) { Date.new((MultiTenantService.statefile.end_of_current_tax_year.year - 60), 1, 1) }

    it 'succeeds' do
      get :edit
      expect(response).to be_successful
    end

    context "single" do
      context "primary is within 62-65 years old" do
        before do
          intake.update(primary_birth_date: between_dob)
        end

        it "primary_disabled questions" do
          get :edit, params: {}
          expect(response).to render_template :edit
          expect(response.body).to include(I18n.t('state_file.questions.id_disability.edit.question'))
        end
      end
    end

    context "mfj" do
      let(:intake) { create :state_file_id_intake, :with_spouse, filing_status: :married_filing_jointly }
      context "both filers are within 62-65 years old" do
        before do
          intake.update(primary_birth_date: between_dob)
          intake.update(spouse_birth_date: between_dob)
        end
        it "shows mfj disability questions for both filers" do
          get :edit, params: {}
          expect(response).to render_template :edit
          expect(response.body).to include(I18n.t('state_file.questions.id_disability.edit.question_both'))
        end
      end

      context "only primary is within 62-65 years old" do
        before do
          intake.update(primary_birth_date: between_dob)
          intake.update(spouse_birth_date: not_between_dob)
        end

        it "primary_disabled questions" do
          get :edit, params: {}
          expect(response).to render_template :edit
          expect(response.body).to include(I18n.t('state_file.questions.id_disability.edit.question'))
        end
      end

      context "only spouse is within 62-65 years old" do
        before do
          intake.update(primary_birth_date: not_between_dob)
          intake.update(spouse_birth_date: between_dob)
        end
        it "spouse_disabled questions" do
          get :edit, params: {}
          expect(response).to render_template :edit
          expect(response.body).to include(I18n.t('state_file.questions.id_disability.edit.question_spouse'))
        end
      end
    end
  end

  describe ".show?" do
    let(:intake) { create :state_file_id_intake}
    let!(:state_file1099_r) { create(:state_file1099_r, intake: intake, taxable_amount: 25) }

    context "when single" do
      context "when feature flag is disabled" do
        before do
          allow(Flipper).to receive(:enabled?).with(:show_retirement_ui).and_return(false)
        end

        it "does not show" do
          expect(described_class.show?(intake)).to eq false
        end
      end
    end

    context "with married filing separately status" do
      let(:intake) { create :state_file_id_intake, filing_status: "married_filing_separately" }

      it "does not show" do
        expect(described_class.show?(intake)).to eq false
      end
    end

    context "has_filer_between_62_and_65_years_old?" do
      context "meets requirements" do
        before do
          allow(intake).to receive(:has_filer_between_62_and_65_years_old?).and_return(true)
        end

        it "does not show" do
          expect(described_class.show?(intake)).to eq true
        end
      end

      context "does not meet requirements" do
        before do
          allow(intake).to receive(:has_filer_between_62_and_65_years_old?).and_return(false)
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
          post :update, params: form_params.merge({return_to_review_before: StateFile::Questions::IdDisabilityController.name.demodulize.underscore,
                                                   return_to_review_after: "retirement_income_deduction"})
          expect(response).to redirect_to(StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper(item_index: 0,
                                                                                                                      return_to_review_before: StateFile::Questions::IdDisabilityController.name.demodulize.underscore,
                                                                                                                      return_to_review_after: "retirement_income_deduction"))
        end

        context "with no eligible 1099Rs" do
          before do
            state_file1099_r.update(taxable_amount: 0)
          end

          it "goes back to the final review screen" do
            post :update, params: form_params.merge({return_to_review_before: StateFile::Questions::IdDisabilityController.name.demodulize.underscore,
                                                     return_to_review_after: "retirement_income_deduction"})
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
          post :update, params: form_params.merge({return_to_review_before: StateFile::Questions::IdDisabilityController.name.demodulize.underscore,
                                                   return_to_review_after: "retirement_income_deduction"})
          expect(response).to redirect_to(StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper(item_index: 0,
                                                                                                                      return_to_review_before: StateFile::Questions::IdDisabilityController.name.demodulize.underscore,
                                                                                                                      return_to_review_after: "retirement_income_deduction"))
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
          expect(response).to redirect_to(StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper(item_index: 0))
        end
      end

      context "has disability in household" do
        let(:primary_disabled) { "yes" }

        before do
          intake.update(primary_disabled: "yes")
        end

        it "should show the Id Retirement and Pension income controller" do
          post :update, params: form_params
          expect(response).to redirect_to(StateFile::Questions::IdRetirementAndPensionIncomeController.to_path_helper(item_index: 0))
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

