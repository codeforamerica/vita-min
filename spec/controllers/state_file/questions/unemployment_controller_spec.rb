require "rails_helper"

RSpec.describe StateFile::Questions::UnemploymentController do
  let(:intake) { create :state_file_ny_intake, filing_status: :married_filing_jointly, spouse_first_name: "Glenn", spouse_last_name: "Gary" }
  before do
    session[:state_file_intake] = intake.to_global_id
  end

  describe "#index" do
    context "with existing dependents" do
      render_views
      let!(:form1099a) { create :state_file1099_g, intake: intake, recipient: :primary }
      let!(:form1099b) { create :state_file1099_g, intake: intake, recipient: :spouse }

      it "renders information about each dependent" do
        get :index, params: { us_state: :ny }

        expect(response.body).to include intake.primary.full_name
        expect(response.body).to include intake.spouse.full_name
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
        us_state: :ny,
        state_file1099_g: {
          had_box_11: 'yes',
          payer_name_is_default: 'yes',
          recipient: 'primary',
          address_confirmation: 'yes',
          payer_name: '',
          federal_income_tax_withheld: 123,
          state_income_tax_withheld: 456,
          unemployment_compensation: 789,
        }
      }
    end

    it "creates a new dependent linked to the current intake and redirects to the index" do
      expect do
        post :create, params: params
      end.to change(StateFile1099G, :count).by 1

      expect(response).to redirect_to(StateFile::Questions::UnemploymentController.to_path_helper(action: :index, us_state: :ny))

      state_file1099_g = StateFile1099G.last
      expect(state_file1099_g.intake).to eq intake
      expect(state_file1099_g.had_box_11).to eq 'yes'
      expect(state_file1099_g.payer_name_is_default).to eq 'yes'
      expect(state_file1099_g.recipient).to eq 'primary'
      expect(state_file1099_g.address_confirmation).to eq "yes"
      expect(state_file1099_g.federal_income_tax_withheld).to eq 123
      expect(state_file1099_g.state_income_tax_withheld).to eq 456
      expect(state_file1099_g.unemployment_compensation).to eq 789
    end

    context "with invalid params" do
      render_views

      let(:params) do
        {
          us_state: :ny,
          state_file1099_g: {
            recipient: :globgor,
          }
        }
      end

      it "renders new with validation errors" do
        expect do
          post :create, params: params
        end.not_to change(StateFile1099G, :count)

        expect(response).to render_template(:new)

        expect(response.body).to include "is not included in the list"
      end
    end
  end

  describe "#edit" do
    let(:client) { intake.client }
    let!(:form1099) do
      create :state_file1099_g,
             intake: intake,
             recipient: 'primary',
             unemployment_compensation: 456
    end
    let(:params) { { us_state: :ny, id: form1099.id } }

    render_views

    it "renders information about the existing dependent" do
      get :edit, params: params

      expect(response.body).to include("456")
    end
  end

  describe "#update" do
    let!(:form1099) do
      create :state_file1099_g,
             intake: intake,
             had_box_11: 'yes',
             payer_name_is_default: 'yes',
             recipient: 'primary',
             address_confirmation: 'yes',
             payer_name: '',
             federal_income_tax_withheld: 123,
             state_income_tax_withheld: 456,
             unemployment_compensation: 789
    end
    let(:params) do
      {
        us_state: :ny,
        id: form1099.id,
        state_file1099_g: {
          had_box_11: 'yes',
          payer_name_is_default: 'yes',
          recipient: 'spouse',
          address_confirmation: 'yes',
          payer_name: '',
          federal_income_tax_withheld: 123,
          state_income_tax_withheld: 456,
          unemployment_compensation: 789,
        }
      }
    end

    it "updates the dependent and redirects to the index" do
      post :update, params: params

      expect(response).to redirect_to(StateFile::Questions::UnemploymentController.to_path_helper(us_state: :ny, action: :index))

      form1099.reload
      expect(form1099.recipient).to eq "spouse"
    end

    context "with invalid params" do
      render_views

      let(:params) do
        {
          us_state: :ny,
          id: form1099.id,
          state_file1099_g: {
            recipient: :globgor,
          }
        }
      end

      it "renders edit with validation errors" do
        expect do
          post :update, params: params
        end.not_to change(StateFile1099G, :count)

        expect(response).to render_template(:edit)

        expect(response.body).to include "is not included in the list"
      end
    end
  end

  describe "#destroy" do
    let!(:form1099) do
      create :state_file1099_g,
             intake: intake,
             recipient: 'primary'
    end
    let(:params) { { us_state: :ny, id: form1099.id } }

    it "deletes the 1099 and adds a flash message and redirects to index path" do
      expect do
        delete :destroy, params: params
      end.to change(StateFile1099G, :count).by(-1)

      expect(response).to redirect_to StateFile::Questions::UnemploymentController.to_path_helper(us_state: :ny, action: :index)
      expect(flash[:notice]).to eq I18n.t('state_file.questions.unemployment.destroy.removed', name: intake.primary.full_name)
    end
  end
end
