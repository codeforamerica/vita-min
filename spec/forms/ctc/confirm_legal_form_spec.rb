require 'rails_helper'

describe Ctc::ConfirmLegalForm do
  let(:client) { create :client, tax_returns: [(create :tax_return, filing_status: nil)] }
  let!(:intake) { create :ctc_intake, client: client }
  let(:params) { { consented_to_legal: "yes" } }

  context "validations" do
    context "when consented to legal is selected" do
      it "is valid" do
        expect(
          described_class.new(intake, params)
        ).to be_valid
      end
    end

    context "when consented to legal is not selected" do
      before do
        params[:consented_to_legal] = "no"
      end

      it "is not valid" do
        form = described_class.new(intake, params)
        expect(form).not_to be_valid
        expect(form.errors.keys).to include(:consented_to_legal)
      end
    end
  end

  context "save" do
    it "persists the consented to legal to intake and create an efile submission and set status to preparing" do
      expect { described_class.new(intake, params).save }
        .to change(intake.reload, :consented_to_legal).from("unfilled").to("yes")
                                                      .and change(intake.tax_returns.last.efile_submissions, :count).by(1)
    end

    context 'when a submission already exists' do
      before do
        create :efile_submission, tax_return: intake.tax_returns.last
      end

      it "does not create another one" do
        expect { described_class.new(intake, params).save }
          .not_to change(intake.tax_returns.last.efile_submissions, :count)
      end
    end
  end
end