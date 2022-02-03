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
        post :generate, params: default_params.merge({ submit_married_filing_jointly_with_dependents: 'Married Filing Jointly With Dependents ✨' })
        expect(controller.current_intake.tax_returns.last).to be_filing_status_married_filing_jointly
        expect(controller.current_intake.dependents.count).to eq(2)
        expect(controller.current_intake.dependents.select { |d| d.eligible_for_child_tax_credit_2020? }.length).to eq(1)
        expect(controller.current_intake.dependents.select { |d| !d.eligible_for_child_tax_credit_2020? && d.yr_2020_qualifying_relative? }.length).to eq(1)
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

      it 'can generate a married filing jointly intake' do
        post :generate, params: default_params.merge({ submit_married_filing_jointly: 'Married Filing Jointly ✨' })
        expect(controller.current_intake).to be_filing_joint_yes
      end

      it 'can generate a married filing jointly with dependents intake' do
        post :generate, params: default_params.merge({ submit_married_filing_jointly_with_dependents: 'Married Filing Jointly With Dependents ✨' })
        expect(controller.current_intake).to be_filing_joint_yes
        expect(controller.current_intake.dependents.count).to eq(2)
      end
    end
  end

  describe '#show' do
    render_views

    context 'for the gyr flow' do
      it 'renders successfully' do
        get :show, params: { id: :gyr }

        expect(response.body).to have_content('GetYourRefund Flow')
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
          create(:tax_return, year: 2021, client: client)
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

    context 'for a nonexistant flow' do
      it 'renders 404' do
        expect do
          get :show, params: { id: :aardvark }
        end.to raise_error(ActionController::RoutingError)
      end
    end
  end
end
