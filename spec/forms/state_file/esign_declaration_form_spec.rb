require "rails_helper"

RSpec.describe StateFile::EsignDeclarationForm do
  let!(:intake) { create :state_file_az_intake, esigned_return: "unfilled", esigned_return_at: nil }
  let(:params) do
    { esigned_return: "yes" }
  end

  describe "#save" do
    context "when has agreed to esign in arizona" do
      it "esigns the return" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.esigned_return).to eq "yes"
        expect(intake.esigned_return_at).to be_present
      end

      it "creates a submission" do
        expect {
          described_class.new(intake, params).save
        }.to change(EfileSubmission, :count).by(1)

        expect(EfileSubmission.last.data_source).to eq intake
      end
    end

    context "when has agreed to esign in new york" do
      let!(:intake) { create :state_file_ny_intake, esigned_return: "unfilled", esigned_return_at: nil }

      it "esigns the return" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.esigned_return).to eq "yes"
        expect(intake.esigned_return_at).to be_present
      end
    end
  end

end
# todo: make sure we esign in the XML