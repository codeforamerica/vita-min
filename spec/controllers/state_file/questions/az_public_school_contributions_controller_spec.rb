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
          ctds_code: '123456789',
          district_name: 'District A',
          amount: 100,
          date_of_contribution_month: '8',
          date_of_contribution_day: "12",
          date_of_contribution_year: "2023"
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
      expect(contribution.amount).to eq 100
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
            made_contribution: nil,
          }
        }
      end

      it "renders new with validation errors" do
        expect do
          post :create, params: invalid_params
        end.not_to change(Az322Contribution, :count)

        expect(response).to render_template(:new)
        expect(response.body).to include "Can't be blank"
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
          ctds_code: '123456789',
          district_name: 'District A',
          amount: 100,
          date_of_contribution_month: '8',
          date_of_contribution_day: "12",
          date_of_contribution_year: "2023"
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
            mad_contribution: "yes",
            school_name: nil,
            ctds_code: nil
          }
        }
      end

      it "renders edit with validation errors" do
        expect do
          post :update, params: invalid_params
        end.not_to change(Az322Contribution, :count)

        expect(response).to render_template(:edit)
        expect(response.body).to include "Can't be blank"
        expect(response.body).to include "School Code/CTDS must be a 9 digit number"
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
    it "has index as default" do
      action = StateFile::Questions::AzPublicSchoolContributionsController.navigation_actions.first
      expect(action).to eq :index
    end
  end
end

