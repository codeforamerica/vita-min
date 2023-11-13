require "rails_helper"

RSpec.describe StateFile::EsignDeclarationForm do
  let!(:intake) { create :state_file_az_intake, primary_esigned: "unfilled", primary_esigned_at: nil, spouse_esigned: "unfilled" }
  let(:params) do
    { primary_esigned: "yes" }
  end

  describe "#save" do
    context "when has agreed to esign in arizona" do
      it "esigns the return" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.primary_esigned).to eq "yes"
        expect(intake.primary_esigned_at).to be_present
      end

      it "creates a submission" do
        expect {
          described_class.new(intake, params).save
        }.to change(EfileSubmission, :count).by(1)

        expect(EfileSubmission.last.data_source).to eq intake
      end
    end

    context "when has agreed to esign in new york" do
      let!(:intake) {
        create :state_file_ny_intake,
               primary_esigned: "unfilled",
               primary_esigned_at: nil,
               spouse_esigned: "unfilled",
               spouse_esigned_at: nil,
               filing_status: :married_filing_jointly
      }
      let(:params) do
        {
          primary_esigned: "yes",
          spouse_esigned: "yes"
        }
      end

      it "esigns the return" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
        form.save

        intake.reload
        expect(intake.primary_esigned).to eq "yes"
        expect(intake.primary_esigned_at).to be_present
        expect(intake.spouse_esigned).to eq "yes"
        expect(intake.spouse_esigned_at).to be_present
      end
    end
  end

end