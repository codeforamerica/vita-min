require "rails_helper"

RSpec.describe FlowsController do
  describe '#generate' do
    context 'for a ctc intake' do
      let(:default_params) do
        {
          type: :ctc,
          flows_controller_sample_intake_form: {
            first_name: 'Testuser',
            last_name: 'Testuser',
            email_address: 'testuser@example.com',
          },
        }
      end

      it 'can generate a single intake' do
        post :generate, params: default_params.merge({ submit_single: 'Single ✨' })
        expect(controller.current_intake.tax_returns.last).to be_filing_status_single
      end

      it 'can generate a married filing jointly intake' do
        post :generate, params: default_params.merge({ submit_married_filing_jointly: 'Married Filing Jointly ✨' })
        expect(controller.current_intake.tax_returns.last).to be_filing_status_married_filing_jointly
      end

      it 'can generate a married filing jointly with dependents intake' do
        default_params[:flows_controller_sample_intake_form][:with_dependents] = '1'
        post :generate, params: default_params.merge({ submit_married_filing_jointly: 'Married Filing Jointly ✨' })
        expect(controller.current_intake.tax_returns.last).to be_filing_status_married_filing_jointly
        expect(controller.current_intake.dependents.count).to eq(2)
        expect(controller.current_intake.dependents.select { |d| d.qualifying_ctc? }.length).to eq(1)
        expect(controller.current_intake.dependents.select { |d| !d.qualifying_ctc? && d.qualifying_relative? }.length).to eq(1)
      end

      it 'can generate a claiming_eitc intake' do
        default_params[:flows_controller_sample_intake_form][:with_dependents] = '1'
        default_params[:flows_controller_sample_intake_form][:claiming_eitc] = '1'
        post :generate, params: default_params.merge({ submit_married_filing_jointly: 'Married Filing Jointly ✨' })
        expect(controller.current_intake.tax_returns.last).to be_filing_status_married_filing_jointly
        expect(controller.current_intake.dependents.count).to eq(2)
        expect(controller.current_intake.dependents.select { |d| d.qualifying_ctc? }.length).to eq(1)
        expect(controller.current_intake.dependents.select { |d| !d.qualifying_ctc? && d.qualifying_relative? }.length).to eq(1)
        expect(controller.current_intake.w2s_including_incomplete.count).to eq(1)
        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: controller.current_intake.tax_returns.first, dependents: controller.current_intake.dependents)
        expect(benefits_eligibility.claiming_and_qualified_for_eitc_pre_w2s?).to be_truthy
      end

      it 'can generate a submission_rejected intake' do
        create(:efile_error, auto_cancel: false, auto_wait: false, expose: true)

        default_params[:flows_controller_sample_intake_form][:submission_rejected] = '1'
        post :generate, params: default_params.merge({ submit_married_filing_jointly: 'Married Filing Jointly ✨' })

        tax_return = controller.current_intake.tax_returns.last
        expect(tax_return).to be_filing_status_married_filing_jointly

        efile_submission = tax_return.efile_submissions.last
        expect(efile_submission.current_state).to eq("failed")
        expect(efile_submission.last_transition.efile_errors.last).to be_present
      end
    end

    context 'for a gyr intake' do
      let(:default_params) do
        {
          type: :gyr,
          flows_controller_sample_intake_form: {
            first_name: 'Testuser',
            last_name: 'Testuser',
            email_address: 'testuser@example.com',
          },
        }
      end

      it 'can generate a single intake' do
        post :generate, params: default_params.merge({ submit_single: 'Single ✨' })
        expect(controller.current_intake).to be_filing_joint_no
      end

      it 'accepts phone numbers without country code' do
        params = default_params.merge({ submit_single: 'Single ✨' })
        params[:flows_controller_sample_intake_form][:sms_phone_number] = '5551112222'
        post :generate, params: params
        expect(controller.current_intake.sms_phone_number).to eq('+15551112222')
      end

      it 'can generate a married filing jointly intake' do
        post :generate, params: default_params.merge({ submit_married_filing_jointly: 'Married Filing Jointly ✨' })
        expect(controller.current_intake).to be_filing_joint_yes
      end

      it 'can generate a married filing jointly with dependents intake' do
        default_params[:flows_controller_sample_intake_form][:with_dependents] = '1'
        post :generate, params: default_params.merge({ submit_married_filing_jointly: 'Married Filing Jointly ✨' })
        expect(controller.current_intake).to be_filing_joint_yes
        expect(controller.current_intake.dependents.count).to eq(2)
      end

      it 'ignores email address when formatted as an array' do
        default_params[:flows_controller_sample_intake_form][:email_address] = ['testuser@example.com']
        post :generate, params: default_params
        expect(controller.current_intake.email_address).to be_nil
      end
    end

    context 'for a state file az intake' do
      let(:default_params) do
        {
          type: :state_file_az,
          flows_controller_sample_intake_form: {
            first_name: 'Testuser',
            last_name: 'Testuser',
            email_address: 'testuser@example.com',
          },
        }
      end

      it 'can generate a single intake' do
        expect do
          post :generate, params: default_params.merge({ submit_single: 'Single ✨'})
        end.to change(StateFileAzIntake, :count).by(1)
        expect(controller.current_intake.filing_status).to eq(:single)
      end

      it 'can generate a married filing jointly intake' do
        expect do
          post :generate, params: default_params.merge({ submit_married_filing_jointly: 'Married Filing Jointly ✨' })
        end.to change(StateFileAzIntake, :count).by(1)
        expect(controller.current_intake.filing_status).to eq(:married_filing_jointly)
      end

      it 'can generate a qualifying widow intake' do
        expect do
          post :generate, params: default_params.merge({ submit_qualifying_widow: 'Qualifying Widow ✨' })
        end.to change(StateFileAzIntake, :count).by(1)
        expect(controller.current_intake.filing_status).to eq(:head_of_household) # In the AZ intake model we treat qualifying widow as hoh
      end

      it 'can generate a married filing separately intake' do
        expect do
          post :generate, params: default_params.merge({ submit_married_filing_separately: 'Married Filing Separately ✨' })
        end.to change(StateFileAzIntake, :count).by(1)
        expect(controller.current_intake.filing_status).to eq(:married_filing_separately)
      end

      it 'can generate a head of household intake' do
        expect do
          post :generate, params: default_params.merge({ submit_head_of_household: 'Head Of Household ✨' })
        end.to change(StateFileAzIntake, :count).by(1)
        expect(controller.current_intake.filing_status).to eq(:head_of_household)
      end
    end

    context 'for a state file ny intake' do
      let(:default_params) do
        {
          type: :state_file_ny,
          flows_controller_sample_intake_form: {
            first_name: 'Testuser',
            last_name: 'Testuser',
            email_address: 'testuser@example.com',
          },
        }
      end

      it 'can generate a single intake' do
        expect do
          post :generate, params: default_params.merge({ submit_head_of_household: 'Head Of Household ✨' })
        end.to change(StateFileNyIntake, :count).by(1)
        expect(controller.current_intake).to be_a(StateFileNyIntake)
        expect(controller.current_intake.filing_status).to eq(:head_of_household)
      end
    end
  end

  describe '#show' do
    render_views

    context 'for the gyr flow' do
      context "when on the gyr hostname" do
        before do
          @request.host = MultiTenantService.new(:gyr).host
        end

        it 'renders successfully' do
          get :show, params: { id: :gyr }

          expect(response.body).to have_content('GetYourRefund Flow')
        end
      end

      context "when on the ctc hostname" do
        before do
          @request.host = MultiTenantService.new(:ctc).host
        end

        it "redirects to the gyr hostname" do
          get :show, params: { id: :gyr }

          expect(response).to redirect_to(flow_url(id: :gyr, host: MultiTenantService.new(:gyr).host))
        end
      end
    end

    context 'for the ctc flow' do
      let(:host) { MultiTenantService.new(:ctc).host }

      before do
        @request.host = host
      end

      it 'renders successfully' do
        get :show, params: { id: :ctc }

        expect(response.body).to have_content('CTC Flow')
      end

      context "with a current_intake" do
        before do
          client = create(:ctc_intake).client
          create(:ctc_tax_return, client: client)
          sign_in client
        end

        it 'renders successfully' do
          get :show, params: { id: :ctc }

          expect(response.body).to have_content('CTC Flow')
        end
      end

      context "with a hostname other than the ctc hostname" do
        let(:host) { 'any-other-hostname' }

        it "redirects to the ctc hostname" do
          get :show, params: { id: :ctc }

          expect(response).to redirect_to(flow_url(id: :ctc, host: MultiTenantService.new(:ctc).host))
        end
      end
    end

    context 'for the state file az flow' do
      let(:host) { MultiTenantService.new(:statefile).host }

      before do
        @request.host = host
      end

      it 'renders successfully' do
        get :show, params: { id: :state_file_az }

        expect(response.body).to have_content('State File - Arizona')
      end
    end

    context 'for the state file ny flow' do
      let(:host) { MultiTenantService.new(:statefile).host }

      before do
        @request.host = host
      end

      it 'renders successfully' do
        get :show, params: { id: :state_file_ny }

        expect(response.body).to have_content('State File - New York')
      end
    end

    context 'for a nonexistent flow' do
      it 'renders 404' do
        expect do
          get :show, params: { id: :aardvark }
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
