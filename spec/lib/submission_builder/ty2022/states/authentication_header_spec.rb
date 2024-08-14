require 'rails_helper'

describe SubmissionBuilder::AuthenticationHeader do
  describe '.build' do

    context "when no state_id is defined" do
      let(:intake) { create(:state_file_ny_intake) }
      let(:submission) { create(:efile_submission, data_source: intake) }

      it "builds generates xml indicating there is no id" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DoNotHaveDrvrLcnsOrStIssdId").text).to eq "X"
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdNum")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdStCd")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdExprDt")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdIssueDt")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsNum")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsStCd")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsExprDt")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsIssueDt")).to eq nil
      end
    end

    context "when a New York drivers license is defined" do
      let(:state_id) { create(:state_id)}
      let(:intake) { create(:state_file_ny_intake, primary_state_id: state_id) }
      let(:submission) { create(:efile_submission, data_source: intake) }

      it "builds an xml with a drivers license" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DoNotHaveDrvrLcnsOrStIssdId")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdNum")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdAddInfo")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdStCd")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdExprDt")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdIssueDt")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsNum").text).to eq "123456789"
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsAddInfo").text).to eq "123"
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsStCd").text).to eq "NY"
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsExprDt ExprDt").text).to eq "2028-11-11"
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsIssueDt").text).to eq "2020-11-11"
      end
    end

    context "when a drivers license which does not expire is defined" do
      let(:state_id) { create(:state_id, :non_expiring)}
      let(:intake) { create(:state_file_ny_intake, primary_state_id: state_id) }
      let(:submission) { create(:efile_submission, data_source: intake) }

      it "builds an xml with a no expiration date info license" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsExprDt ExprDt")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsExprDt NonExpr")).to be_truthy
      end
    end

    context "when a non New York drivers license is defined" do
      let(:state_id) { create(:state_id, :non_ny)}
      let(:intake) { create(:state_file_ny_intake, primary_state_id: state_id) }
      let(:submission) { create(:efile_submission, data_source: intake) }

      it "builds an xml with a no additonal info" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdNum")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsAddInfo")).to eq nil
      end
    end


    context "when a New York state issued id is defined" do
      let(:state_id) { create(:state_id, :state_issued_id)}
      let(:intake) { create(:state_file_ny_intake, primary_state_id: state_id) }
      let(:submission) { create(:efile_submission, data_source: intake) }

      it "builds an xml with a no additonal info" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DoNotHaveDrvrLcnsOrStIssdId")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsNum")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsAddInfo")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsStCd")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsExprDt")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsIssueDt")).to eq nil

        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdNum").text).to eq "123456789"
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdAddInfo").text).to eq "123"
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdStCd").text).to eq "NY"
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdExprDt ExprDt").text).to eq "2028-11-11"
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdIssueDt").text).to eq "2020-11-11"
      end
    end
  end

  describe '#refund_disbursement' do
    let(:state_id) { create(:state_id, :state_issued_id)}
    let(:intake) { create(:state_file_ny_intake, primary_state_id: state_id) }
    let(:submission) { create(:efile_submission, data_source: intake) }

    context 'when a submission is not receiving a refund' do
      it 'build the XML with the correct refund disbursement tag' do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at('NoUBADisbursementCdSubmit').text).to eq '0'
      end
    end

    context 'when a submission is receiving a refund with payment_or_deposit_type of mail' do
      before do
        allow_any_instance_of(StateFileNyIntake).to receive(:calculated_refund_or_owed_amount).and_return(100)
        allow_any_instance_of(StateFileNyIntake).to receive(:payment_or_deposit_type).and_return('mail')

      end
      it 'builds the XML with the correct refund disbursement tag' do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at('NoUBADisbursementCdSubmit').text).to eq '3'
      end
    end

    context 'when a submission is receiving a refund with payment_or_deposit_type of direct deposit' do
      before do
        allow_any_instance_of(StateFileNyIntake).to receive(:calculated_refund_or_owed_amount).and_return(100)
        allow_any_instance_of(StateFileNyIntake).to receive(:payment_or_deposit_type).and_return('direct_deposit')

      end
      it 'builds the XML with the correct refund disbursement tag' do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at('RefundDisbursementUBASubmit').text).to eq '2'
      end
    end
  end
end