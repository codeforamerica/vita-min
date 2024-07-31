# frozen_string_literal: true
require "rails_helper"

RSpec.describe StateFile::Questions::AzPublicSchoolContributionsController do
  let(:intake) { create :state_file_az_intake }
  before do
    sign_in intake
  end

  describe "#index" do
    context "with existing contributions" do
      render_views
      let!(:contribution) { create :az322_contribution, state_file_az_intake: intake }

      it "renders information about each contribution" do
        get :index
        expect(response.body).to include contribution.school_name
      end
    end

    context "with no existing contributions" do
      render_views
      it "redirects to the new view" do
        get :index
        expect(response).to redirect_to action: :new
      end
    end
  end

  describe "#new" do
    it "builds a new contribution" do
      get :new
      expect(assigns(:az322_contribution)).to be_a_new(Az322Contribution)
    end
  end

  describe "#create" do
    let(:params) do
      {
        az322_contribution: {
          made_contribution: 'yes',
          school_name: 'School A',
          ctds_code: '123456',
          district_name: 'District A',
          amount: 100,
          date_of_contribution: '2023-01-01'
        }
      }
    end

    it "creates a new contribution linked to the current intake and redirects to the index" do
      expect do
        post :create, params: params
      end.to change(Az322Contribution, :count).by 1

      expect(response).to redirect_to(action: :index)

      contribution = Az322Contribution.last
      expect(contribution.state_file_az_intake).to eq intake
      expect(contribution.school_name).to eq 'School A'
    end

    context "when 'no' was selected for made_contribution" do
      before do
        params[:az322_contribution][:made_contribution] = 'no'
      end

      it "creates nothing" do
        expect do
          post :create, params: params
        end.not_to change(Az322Contribution, :count)
      end
    end

    context "with invalid params" do
      render_views
      let(:invalid_params) do
        {
          az322_contribution: {
            school_name: nil,
          }
        }
      end
    end
  end

  describe "#edit" do
    let!(:contribution) { create :az322_contribution, state_file_az_intake: intake }
    let(:params) { { id: contribution.id } }

    render_views

    it "renders information about the existing contribution" do
      get :edit, params: params
      expect(response.body).to include contribution.school_name
    end
  end

  describe "#update" do
    let!(:contribution) { create :az322_contribution, state_file_az_intake: intake, school_name: 'Old School' }
    let(:params) do
      {
        id: contribution.id,
        az322_contribution: {
          made_contribution: 'yes',
          school_name: 'New School',
        }
      }
    end

    it "updates the contribution and redirects to the index" do
      post :update, params: params
      expect(response).to redirect_to(action: :index)

      contribution.reload
      expect(contribution.school_name).to eq 'New School'
    end

    context "when 'no' was selected for made_contribution" do
      before do
        params[:az322_contribution][:made_contribution] = 'no'
      end

      it "deletes the contribution" do
        expect do
          post :update, params: params
        end.to change(Az322Contribution, :count).by(-1)

        expect { contribution.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with invalid params" do
      render_views
      let(:invalid_params) do
        {
          id: contribution.id,
          az322_contribution: {
            school_name: nil,
          }
        }
      end
    end
  end

  describe "#destroy" do
    let!(:contribution) { create :az322_contribution, state_file_az_intake: intake }
    let(:params) { { id: contribution.id } }

    it "deletes the contribution and adds a flash message and redirects to index path" do
      expect do
        delete :destroy, params: params
      end.to change(Az322Contribution, :count).by(-1)

      expect(response).to redirect_to action: :index
      expect(flash[:notice]).to eq I18n.t('state_file.questions.az_public_school_contributions.destroy.removed', school_name: contribution.school_name)
    end
  end

  describe "navigation" do
    it "has index and new as navigation actions" do
      actions = StateFile::Questions::AzPublicSchoolContributionsController.navigation_actions
      expect(actions).to eq [:index, :new]
    end
  end
end

