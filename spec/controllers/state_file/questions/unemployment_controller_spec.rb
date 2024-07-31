require "rails_helper"

RSpec.describe StateFile::Questions::UnemploymentController do
  let(:intake) { create :state_file_ny_intake, filing_status: :married_filing_jointly, spouse_first_name: "Glenn", spouse_last_name: "Gary" }
  before do
    sign_in intake
  end

  describe ".show?" do
    it "is true for a return with unemployment income" do
      intake = create :state_file_ny_intake, raw_direct_file_data: StateFile::XmlReturnSampleService.new.read("az_unemployment")
      expect(described_class.show?(intake)).to be_truthy
    end

    it "is false for a return that did not have unemployment income" do
      intake = create :state_file_ny_intake, raw_direct_file_data: StateFile::XmlReturnSampleService.new.read("ny_single_w2")
      expect(described_class.show?(intake)).to be_falsey
    end

    it "is false for a return that has a zero unemployment income" do
      intake = create :state_file_ny_intake, raw_direct_file_data: StateFile::XmlReturnSampleService.new.read("ny_educator_deduction")
      expect(described_class.show?(intake)).to be_falsey
    end
  end

  describe "#index" do
    context "with existing dependents" do
      render_views
      let!(:form1099a) { create :state_file1099_g, intake: intake, recipient: :primary }
      let!(:form1099b) { create :state_file1099_g, intake: intake, recipient: :spouse }

      it "renders information about each dependent" do
        get :index

        expect(response.body).to include intake.primary.full_name
        expect(response.body).to include intake.spouse.full_name
      end
    end

    context "with no existing dependents" do
      render_views
      it "redirects to the new view" do
        get :index
        expect(response).to redirect_to StateFile::Questions::UnemploymentController.to_path_helper(action: :new)
      end
    end
  end

  describe "#create" do
    let(:params) do
      {
        state_file1099_g: {
          had_box_11: 'yes',
          recipient: 'primary',
          address_confirmation: 'yes',
          payer_name: 'Business',
          payer_street_address: '123 Main St',
          payer_city: 'New York',
          payer_zip: '11102',
          payer_tin: '270293117',
          federal_income_tax_withheld: 123,
          state_income_tax_withheld: 456,
          unemployment_compensation: 789,
          state_identification_number: '123456789',
        }
      }
    end

    it "creates a new dependent linked to the current intake and redirects to the index" do
      expect do
        post :create, params: params
      end.to change(StateFile1099G, :count).by 1

      expect(response).to redirect_to(StateFile::Questions::UnemploymentController.to_path_helper(action: :index))

      state_file1099_g = StateFile1099G.last
      expect(state_file1099_g.intake).to eq intake
      expect(state_file1099_g.had_box_11).to eq 'yes'
      expect(state_file1099_g.recipient).to eq 'primary'
      expect(state_file1099_g.address_confirmation).to eq "yes"
      expect(state_file1099_g.federal_income_tax_withheld).to eq 123
      expect(state_file1099_g.state_income_tax_withheld).to eq 456
      expect(state_file1099_g.unemployment_compensation).to eq 789
    end

    context "when 'no' was selected for had_box_11" do
      before do
        params[:state_file1099_g][:had_box_11] = 'no'
      end

      it "creates nothing" do
        expect do
          post :create, params: params
        end.not_to change(StateFile1099G, :count)
      end
    end

    context "if the intake was anything other than married filing jointly" do
      let(:intake) { create :state_file_ny_intake, filing_status: :single, spouse_first_name: nil, spouse_last_name: nil }

      before do
        params[:state_file1099_g].delete(:recipient)
      end

      it "saves 'recipient' as 'primary'" do
        post :create, params: params

        state_file1099_g = StateFile1099G.last
        expect(state_file1099_g.recipient).to eq 'primary'
      end
    end

    context "with invalid params" do
      render_views

      let(:params) do
        {
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

    context "with a 9 digit zipcode from direct file data" do
      render_views
      #let(:intake) do
      #  intake_ = super()
      #  intake_.update(raw_direct_file_data: intake.raw_direct_file_data.gsub("<ZIPCd>10128</ZIPCd>", "<ZIPCd>123456789</ZIPCd>"))
      #  intake_
      #end

      it "creates a 1099g" do
        expect do
          post :create, params: params
        end.to change(StateFile1099G, :count)
        expect(response).to redirect_to(StateFile::Questions::UnemploymentController.to_path_helper(action: :index))
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
    let(:params) { { id: form1099.id } }

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
             recipient: 'primary',
             address_confirmation: 'yes',
             federal_income_tax_withheld: 123,
             state_income_tax_withheld: 456,
             unemployment_compensation: 789
    end
    let(:params) do
      {
        id: form1099.id,
        state_file1099_g: {
          had_box_11: 'yes',
          recipient: 'spouse',
          address_confirmation: 'yes',
          federal_income_tax_withheld: 123,
          state_income_tax_withheld: 456,
          unemployment_compensation: 789,
        }
      }
    end

    it "updates the dependent and redirects to the index" do
      post :update, params: params

      expect(response).to redirect_to(StateFile::Questions::UnemploymentController.to_path_helper(action: :index))

      form1099.reload
      expect(form1099.recipient).to eq "spouse"
    end

    context "when 'no' was selected for had_box_11" do
      before do
        params[:state_file1099_g][:had_box_11] = 'no'
      end

      it "deletes the 1099" do
        expect do
          post :update, params: params
        end.to change(StateFile1099G, :count).by(-1)

        expect { form1099.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "with invalid params" do
      render_views

      let(:params) do
        {
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
    let(:params) { { id: form1099.id } }

    it "deletes the 1099 and adds a flash message and redirects to index path" do
      expect do
        delete :destroy, params: params
      end.to change(StateFile1099G, :count).by(-1)

      expect(response).to redirect_to StateFile::Questions::UnemploymentController.to_path_helper(action: :index)
      expect(flash[:notice]).to eq I18n.t('state_file.questions.unemployment.destroy.removed', name: intake.primary.full_name)
    end
  end

  describe "navigation" do
    it "has index as the default action" do
      action = StateFile::Questions::UnemploymentController.navigation_actions.first
      expect(action).to eq :index
    end
  end
end
