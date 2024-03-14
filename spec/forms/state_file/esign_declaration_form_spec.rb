require "rails_helper"

RSpec.describe StateFile::EsignDeclarationForm do
  let!(:intake) { create :state_file_az_intake, primary_esigned: "unfilled", primary_esigned_at: nil, spouse_esigned: "unfilled" }
  let!(:efile_device_info){ create :state_file_efile_device_info, :submission, intake: intake }
  let(:device_id) { "AA" * 20 }
  let(:params) do
    { primary_esigned: "yes",
      device_id: device_id,
    }
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
        expect(intake.submission_efile_device_info.device_id).to eq device_id
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
          spouse_esigned: "yes",
          device_id: device_id
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
        expect(intake.submission_efile_device_info.device_id).to eq device_id
      end
    end

    context "when they don't have an existing efile submission" do
      it "creates a new efile submission" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
        expect {
          form.save
        }.to change(intake.efile_submissions, :count).by(1)
        expect(intake.reload.efile_submissions.last.current_state).to eq("bundling")
      end
    end

    # in the case that a client is resubmitting their return
    context "when they have an existing rejected efile submission" do
      let!(:rejected_efile_submission) { create :efile_submission, :rejected, :for_state, data_source: intake }

      it "creates a new efile submission and transitions old one to resubmitted" do
        form = described_class.new(intake, params)
        expect(form).to be_valid
        expect {
          form.save
        }.to change(intake.efile_submissions, :count).by(1)

        expect(rejected_efile_submission.reload.current_state).to eq("resubmitted")
        expect(intake.reload.efile_submissions.last.current_state).to eq("bundling")
      end
    end

    context "when they have an existing waiting efile submission" do
      let!(:rejected_efile_submission) { create :efile_submission, :waiting, :for_state, data_source: intake }

      it "creates a new efile submission and transitions old one to resubmitted" do
        described_class.new(intake, params).save
        expect(rejected_efile_submission.reload.current_state).to eq("resubmitted")
        expect(intake.reload.efile_submissions.last.current_state).to eq("bundling")
      end
    end

    context "when they have an existing notified_of_rejection efile submission" do
      let!(:rejected_efile_submission) { create :efile_submission, :notified_of_rejection, :for_state, data_source: intake }

      it "creates a new efile submission and transitions old one to resubmitted" do
        described_class.new(intake, params).save
        expect(rejected_efile_submission.reload.current_state).to eq("resubmitted")
        expect(intake.reload.efile_submissions.last.current_state).to eq("bundling")
      end
    end
  end

  describe "#validations" do
    let!(:intake) { create :state_file_az_intake, primary_esigned: "unfilled", primary_esigned_at: nil, spouse_esigned: "unfilled", filing_status: "married_filing_jointly" }

    context "when married-filing-jointly and spouse is deceased" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return(true)
        allow(intake).to receive(:spouse_deceased?).and_return(true)
      end

      it "does not require spouse signature" do
        form = StateFile::EsignDeclarationForm.new(
          intake,
          {
            primary_esigned: "yes",
            spouse_esigned: nil,
            device_id: device_id,
          }
        )

        expect(form).to be_valid
      end
    end

    context "when married-filing-jointly and spouse is not deceased" do
      before do
        allow(intake).to receive(:filing_status_mfj?).and_return(true)
        allow(intake).to receive(:spouse_deceased?).and_return(false)
      end

      it "does require spouse signature" do
        form = StateFile::EsignDeclarationForm.new(
          intake,
          {
            primary_esigned: "yes",
            spouse_esigned: "unfilled",
            device_id: device_id,
          }
        )

        expect(form).not_to be_valid
      end
    end
  end

end