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
    let(:form_params) do
      {
        state_file_nc_qss_info_form: {
          spouse_death_year: 2023
        }
      }
    end

    it_behaves_like :return_to_review_concern do

    end
  end
end
