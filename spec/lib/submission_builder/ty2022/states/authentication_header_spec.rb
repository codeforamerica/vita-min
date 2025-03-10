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
      let(:state_id) { create(:state_id) }
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
      let(:state_id) { create(:state_id, :non_expiring) }
      let(:intake) { create(:state_file_ny_intake, primary_state_id: state_id) }
      let(:submission) { create(:efile_submission, data_source: intake) }

      it "builds an xml with a no expiration date info license" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsExprDt ExprDt")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsExprDt NonExpr")).to be_truthy
      end
    end

    context "when a non New York drivers license is defined" do
      let(:state_id) { create(:state_id, :non_ny) }
      let(:intake) { create(:state_file_ny_intake, primary_state_id: state_id) }
      let(:submission) { create(:efile_submission, data_source: intake) }

      it "builds an xml with a no additonal info" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp StateIssdIdNum")).to eq nil
        expect(doc.at("PrimDrvrLcnsOrStateIssdIdGrp DrvrLcnsAddInfo")).to eq nil
      end
    end

    context "when a New York state issued id is defined" do
      let(:state_id) { create(:state_id, :state_issued_id) }
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
    let(:state_id) { create(:state_id, :state_issued_id) }
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

  describe 'email address' do
    let(:intake) { create(:state_file_md_intake) }
    let(:submission) { create(:efile_submission, data_source: intake) }
    context "when intake does not have an email address email address" do
      it "returns the email address in the df xml" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("EmailAddressTxt").text).to eq "beaches@bigtoddsyarnmats.com"
      end
    end

    context "when intake does have an email address email address" do
      before do
        intake.email_address = "example@test.com"
      end
      it "returns the email address in the intake" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("EmailAddressTxt").text).to eq "example@test.com"
      end
    end
  end

  describe "phone number" do
    let(:phone_number) { nil }
    let(:intake) { create(:state_file_az_intake, phone_number: phone_number) }
    let(:submission) { create(:efile_submission, data_source: intake) }

    before do
      intake.direct_file_data.phone_number = "+15551231234"
      intake.direct_file_data.cell_phone_number = "+15551231239"
    end

    context "when there is a phone number on the intake" do
      let(:phone_number) { "+18324658840" }

      it "uses the phone number from the intake" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("USCellPhoneNum").text).to eq "8324658840"
      end
    end

    context "when there is no phone number on the intake but there is one on from the direct file data" do
      it "uses the phone number from the direct file data" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("USCellPhoneNum").text).to eq "5551231234"
      end
    end

    context "when there is no phone number on the intake or direct file data but there is a cell phone number from DF" do
      before do
        intake.direct_file_data.phone_number = ""
      end

      it "uses the cell phone number from the direct file data" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("USCellPhoneNum").text).to eq "5551231239"
      end
    end

    context "when there is no phone number on the intake or direct file data" do
      before do
        intake.direct_file_data.phone_number = ""
        intake.direct_file_data.cell_phone_number = ""
      end

      it "the xml is not present" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("USCellPhoneNum")).not_to be_present
      end
    end
  end

  describe "device id" do
    let(:intake) { create(:state_file_az_intake) }
    let(:submission) { create(:efile_submission, data_source: intake.reload) }
    let!(:initial_efile_device_info) { create :state_file_efile_device_info, :initial_creation, :filled, intake: intake, device_id: device_id }
    let!(:submission_efile_device_info) { create :state_file_efile_device_info, :submission, :filled, intake: intake, device_id: device_id }
    let(:device_id) { "AA" * 20 }

    context "when the device id is alphanumeric 40 character count" do
      let(:device_id) { "7BA1E530D6503F380F1496A47BEB6F33E40403D1" }
      it "sends submitted device id" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("DeviceId").text).to eq "7BA1E530D6503F380F1496A47BEB6F33E40403D1"
      end
    end

    context "when the device id doesn't have a character count of 40" do
      let(:device_id) { "abba" }
      it "sends the default device id" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("DeviceId").text).to eq 'AB' * 20
      end
    end

    context "when the device id is not capitalized alphanumeric characters" do
      let(:device_id) { "aa" * 20 }
      it "sends the default device id" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("DeviceId").text).to eq 'AB' * 20
      end
    end

    context "when the device id is not alphanumeric characters" do
      let(:device_id) { "A*" * 20 }
      it "sends the default device id" do
        doc = SubmissionBuilder::AuthenticationHeader.new(submission).document
        expect(doc.at("DeviceId").text).to eq 'AB' * 20
      end
    end
  end

  context "FirstInput" do
    let(:submission) { create(:efile_submission, data_source: intake) }
    let(:xml) { SubmissionBuilder::AuthenticationHeader.new(submission).document }

    context "in a state that does not require banking information in FinancialResolution" do
      context "refund" do
        let(:intake) { create(:state_file_az_refund_intake) }

        it "leaves FirstInput details blank" do
          expect(xml.at("FirstInput RoutingTransitNum")).to be_nil
          expect(xml.at("FirstInput DepositorAccountNum")).to be_nil
          expect(xml.at("FirstInput InputTimestamp")).to be_nil
        end
      end

      context "owed" do
        let(:intake) { create(:state_file_az_owed_intake) }

        it "leaves FirstInput details blank" do
          expect(xml.at("FirstInput RoutingTransitNum")).to be_nil
          expect(xml.at("FirstInput DepositorAccountNum")).to be_nil
          expect(xml.at("FirstInput InputTimestamp")).to be_nil
        end
      end
    end

    context "in a state that requires banking information in FinancialResolution" do
      context "refund" do
        let(:intake) { create(:state_file_md_refund_intake, primary_esigned_at: DateTime.new(2025, 2, 15, 12).in_time_zone(StateFile::StateInformationService.timezone("md"))) }

        context "with direct_deposit for their refund" do
          before do
            intake.update(payment_or_deposit_type: "direct_deposit")
          end

          it "fills out the FirstInput banking information" do
            expect(xml.at("FirstInput RoutingTransitNum").text).to eq "111111111"
            expect(xml.at("FirstInput DepositorAccountNum").text).to eq "222222222"
            expect(xml.at("FirstInput InputTimestamp").text).to eq "2025-02-15T07:00:00-05:00"
          end
        end

        context "with mail selected for their refund" do
          before do
            intake.update(payment_or_deposit_type: "mail")
          end

          it "leaves FirstInput details blank" do
            expect(xml.at("FirstInput RoutingTransitNum")).to be_nil
            expect(xml.at("FirstInput DepositorAccountNum")).to be_nil
            expect(xml.at("FirstInput InputTimestamp")).to be_nil
          end
        end
      end

      context "owed" do
        let(:intake) { create(:state_file_md_owed_intake, primary_esigned_at: DateTime.new(2025, 2, 15, 12).in_time_zone(StateFile::StateInformationService.timezone("md"))) }

        context "with direct_deposit for their refund" do
          before do
            intake.update(payment_or_deposit_type: "direct_deposit")
          end

          it "fills out the FirstInput banking information" do
            expect(xml.at("FirstInput RoutingTransitNum").text).to eq "111111111"
            expect(xml.at("FirstInput DepositorAccountNum").text).to eq "222222222"
            expect(xml.at("FirstInput InputTimestamp").text).to eq "2025-02-15T07:00:00-05:00"
          end
        end

        context "with mail selected for their refund" do
          before do
            intake.update(payment_or_deposit_type: "mail")
          end

          it "leaves FirstInput details blank" do
            expect(xml.at("FirstInput RoutingTransitNum")).to be_nil
            expect(xml.at("FirstInput DepositorAccountNum")).to be_nil
            expect(xml.at("FirstInput InputTimestamp")).to be_nil
          end
        end
      end
    end
  end
end