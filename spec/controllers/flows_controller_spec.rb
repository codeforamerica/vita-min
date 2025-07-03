require "rails_helper"

RSpec.describe FlowsController do
  describe '#generate' do
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
