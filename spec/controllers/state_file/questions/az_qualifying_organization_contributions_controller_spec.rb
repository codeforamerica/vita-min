require 'rails_helper'

RSpec.describe StateFile::Questions::AzQualifyingOrganizationContributionsController do
  render_views

  let(:intake) { create :state_file_az_intake }

  before do
    sign_in intake
  end

  describe "#index" do
    it 'should skip when no contributions are added' do
      get :index

      expect(response).to redirect_to(:new_az_qualifying_organization_contribution)
    end

    it 'should list contributions' do
      contribution = create(:az321_contribution, state_file_az_intake: intake)

      get :index

      expect(response).to be_ok
      expect(response.body).to include(contribution.charity_name)
    end

    it 'should hide the add another button when three contributions are already created' do
      create_list(:az321_contribution, 3, state_file_az_intake: intake)

      get :index

      expect(response).to be_ok
      expect(response).not_to include('Add another contribution')
    end

    it 'should show the add another button when there are fewer than three contributions' do
      create(:az321_contribution, state_file_az_intake: intake)

      get :index

      expect(response).to be_ok
      expect(response.body).to include('Add another contribution')
    end
  end

  describe "edit" do
    let(:contribution) { create(:az321_contribution, state_file_az_intake: intake)}

    it 'should render information about the contribution' do
      get :edit, params: { id: contribution.id }

      expect(response).to be_ok
      expect(response.body).to include(contribution.charity_name)
      expect(response.body).to include(contribution.charity_code)
      expect(response.body).to include(contribution.amount.to_s("F"))
    end
  end

  describe "update" do
    let(:contribution) do
      create(
        :az321_contribution,
        amount: 50,
        date_of_contribution_year: Rails.configuration.statefile_current_tax_year,
        date_of_contribution_month: 5,
        date_of_contribution_day: 12,
        state_file_az_intake: intake
      )
    end

    it 'should update the contribution when valid' do
      post :update, params: { id: contribution.id, az321_contribution: { amount: 55 } }

      expect(response).to redirect_to(:az_qualifying_organization_contributions)

      contribution.reload

      expect(contribution.amount.to_i).to be(55)
    end

    it 'should not update the contribution when invalid' do
      post :update, params: { id: contribution.id, az321_contribution: { amount: 0 } }

      expect(response).not_to redirect_to(:az_qualifying_organization_contributions)

      contribution.reload

      expect(contribution.amount.to_i).to be(50)
    end

    it 'should populate the date correctly' do
      post :update,
           params: {
             id: contribution.id,
             az321_contribution: {
               date_of_contribution_month: 6,
               date_of_contribution_day: 16
             }
           }

      expect(response).to redirect_to(:az_qualifying_organization_contributions)

      contribution.reload

      expect(contribution.date_of_contribution.to_s).to eq("#{Rails.configuration.statefile_current_tax_year}-06-16")
    end
  end

  describe "new" do
    it 'should assign a new contribution' do
      get :new

      expect(assigns(:contribution)).to be_a_new(Az321Contribution)
    end
  end

  describe "create" do
    let(:valid_params) do
      {
        az321_contribution: {
          state_file_az_intake_attributes: {
            made_az321_contributions: "yes",
          },
          date_of_contribution_month: 5,
          date_of_contribution_day: 12,
          date_of_contribution_year: Rails.configuration.statefile_current_tax_year,
          charity_name: "foo",
          charity_code: "21111",
          amount: 50
        }
      }
    end

    let(:made_az321_contributions_missing_params) do
      {
        az321_contribution: {
          date_of_contribution_month: 5,
          date_of_contribution_day: 12,
          date_of_contribution_year: Rails.configuration.statefile_current_tax_year,
          charity_name: "foo",
          charity_code: "bar",
          amount: 50
        }
      }
    end

    let(:invalid_params) do
      {
        az321_contribution: {
          state_file_az_intake_attributes: {
            made_az321_contributions: "yes",
          },
          date_of_contribution_month: 5,
          date_of_contribution_day: 12,
          date_of_contribution_year: Rails.configuration.statefile_current_tax_year,
          charity_name: "foo",
          charity_code: "bar",
          amount: 0
        }
      }
    end

    it 'should create the contribution when the made_az321_contributions is not missing' do
      expect {
        put :create, params: valid_params
      }.to change(Az321Contribution, :count).from(0).to(1)

      expect(response).to redirect_to(:az_qualifying_organization_contributions)
    end

    it 'should not create the contribution when the made_az321_contributions is missing' do
      expect {
        put :create, params: made_az321_contributions_missing_params
      }.not_to change(Az321Contribution, :count)

      expect(response).not_to be_redirect
    end

    it 'should not create the contribution when the contribution is invalid' do
      expect {
        put :create, params: invalid_params
      }.not_to change(Az321Contribution, :count)

      expect(response).to be_ok
    end
  end

  describe "destroy" do
    let!(:contribution) { create(:az321_contribution, state_file_az_intake: intake)}

    it 'should delete the contribution when valid' do
      expect {
        delete :destroy, params: { id: contribution.id }
      }.to change(Az321Contribution, :count).from(1).to(0)
    end

    it 'should 404 when no contribution is found' do
      expect {
        delete :destroy, params: { id: 8000 }
      }.to raise_error(ActiveRecord::RecordNotFound)

    end
  end
end
