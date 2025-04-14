require 'rails_helper'

RSpec.describe StateFile::Questions::NcQssInfoController do
  let(:intake) { create :state_file_nc_intake }

  before { sign_in intake }

  describe ".show?" do
    context "when filer is qss" do
      before do
        allow(intake).to receive(:filing_status_qw?).and_return(true)
      end

      it "shows" do
        expect(described_class).to be_show(intake)
      end
    end

    context "when filer is not qss" do
      before do
        allow(intake).to receive(:filing_status_qw?).and_return(false)
      end

      it "does not show" do
        expect(described_class).not_to be_show(intake)
      end
    end
  end

  describe "#update" do
    context "when no year is selected" do
      let(:empty_params) do
        {
        }
      end

      it "fails & shows an error" do
        post :update, params: empty_params
        expect(assigns(:form)).not_to be_valid
        expect(assigns(:form).errors[:spouse_death_year]).not_to be_blank
      end
    end

    context "when some invalid year is somehow provided" do
      let(:invalid_params) do
        {
          state_file_nc_qss_info_form: {
            spouse_death_year: 1900
          }
        }
      end

      it "fails & shows an error" do
        post :update, params: invalid_params
        expect(assigns(:form)).not_to be_valid
        expect(assigns(:form).errors[:spouse_death_year]).not_to be_blank
      end
    end

    context "when a valid year is provided" do
      let(:valid_params) do
        {
          state_file_nc_qss_info_form: {
            spouse_death_year: MultiTenantService.statefile.current_tax_year - 1
          }
        }
      end

      it "succeeds" do
        post :update, params: valid_params
        expect(assigns(:form)).to be_valid
        expect(assigns(:form).errors[:spouse_death_year]).to be_blank
      end
    end
  end
end
