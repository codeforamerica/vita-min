require 'rails_helper'

FactoryBot.define do
  factory :johnny, class: StateFileAzIntake do
    raw_direct_file_data { StateFile::XmlReturnSampleService.new.read('az_johnny_mfj_8_deps') }
    primary_first_name { "Johnny" }
    primary_middle_initial { "L" }
    primary_last_name { "Rose" }
    primary_suffix { "SR" }
    primary_birth_date { "1975-01-01" }

    spouse_first_name { "Moira" }
    spouse_last_name { "O'Hara" }
    spouse_birth_date { "1975-02-02" }

    after(:create) do |intake|
      intake.synchronize_df_dependents_to_database

      intake.dependents.where(first_name: "David").first.update(
        dob: Date.new(2015, 1, 1),
        relationship: "DAUGHTER",
        months_in_home: 12
      )
      intake.dependents.where(first_name: "Twyla").first.update(
        dob: Date.new(2017, 1, 2),
        relationship: "NEPHEW",
        months_in_home: 7
      )
      intake.dependents.where(first_name: "Alexis").first.update(
        dob: Date.new(2019, 2, 2),
        relationship: "DAUGHTER",
        months_in_home: 12
      )
      intake.dependents.where(first_name: "Stevie").first.update(
        dob: Date.new(2021, 5, 5),
        relationship: "DAUGHTER",
        months_in_home: 8
      )
      intake.dependents.where(first_name: "Roland").first.update(
        dob: Date.new(1960, 6, 6),
        relationship: "PARENT",
        months_in_home: 12
      )
      intake.dependents.where(first_name: "Ronnie").first.update(
        dob: Date.new(1960, 7, 7),
        relationship: "PARENT",
        months_in_home: 12
      )
      intake.dependents.where(first_name: "Bob").first.update(
        dob: Date.new(1940, 3, 3),
        relationship: "GRANDPARENT",
        months_in_home: 7,
        needed_assistance: "no",
        passed_away: "no"
      )
      intake.dependents.where(first_name: "Wendy").first.update(
        dob: Date.new(1940, 4, 4),
        relationship: "GRANDPARENT",
        months_in_home: 12,
        needed_assistance: "yes",
        passed_away: "no"
      )
      intake.dependents.reload
    end

    has_prior_last_names { "yes" }
    prior_last_names { "Schitt, Creek" }

    tribal_member { "yes" }
    tribal_wages { 1000 }

    armed_forces_member { "no" }

    charitable_contributions { "no" }

    primary_state_id {
      create :state_id,
             id_type: 'driver_license',
             id_number: '123456',
             state: 'AZ',
             issue_date: Date.new(2020, 1, 1),
             expiration_date: Date.new(2027, 1, 1),
             first_three_doc_num: nil
    }

    spouse_state_id {
      create :state_id,
             id_type: 'dmv_bmv',
             id_number: '654321',
             state: 'MN',
             issue_date: Date.new(2021, 1, 1),
             expiration_date: Date.new(2028, 1, 1),
             first_three_doc_num: nil
    }

    payment_or_deposit_type { "direct_deposit" }
    bank_name { "Canvas Credit union" }
    account_type { "checking" }
    routing_number { "302075830" }
    account_number { "123456" }

    federal_submission_id { "12345202201011234570" }
  end
end

describe 'johnny' do
  let(:intake) { create :johnny }
  let(:efile_submission) { create :efile_submission, :accepted, :for_state, data_source: intake }
  let!(:initial_efile_device_info) { create :state_file_efile_device_info, :filled, :initial_creation, updated_at: Time.now - 1.minute, intake: intake }
  let!(:submission_efile_device_info) { create :state_file_efile_device_info, :filled, :submission, intake: intake }

  let(:generated_pdf) { efile_submission.generate_filing_pdf }
  let(:generated_pdf_fields) { PdfForms.new.get_fields(generated_pdf) }
  let(:generated_pdf_fields_hash) { generated_pdf_fields.to_h { |field| [field.name, field.value] } }
  let(:generated_submission_bundle) { SubmissionBundle.new(efile_submission) }

  let(:approved_pdf_path) { 'spec/personas/2023/az/johnny/johnny_return.pdf' }
  let(:approved_pdf_fields) { PdfForms.new.get_fields(File.open(approved_pdf_path)) }
  let(:approved_pdf_fields_hash) { approved_pdf_fields.to_h { |field| [field.name, field.value] } }
  let(:approved_submission_bundle_path) { 'spec/personas/2023/az/johnny/johnny_return_xmls' }

  it 'generates identical filing PDF to approved output' do
    expect(approved_pdf_fields_hash).to match(generated_pdf_fields_hash)
  end

  it 'generates identical submission bundle to approved output' do
    efile_submission.update(irs_submission_id: '1234562024165nly30yy')
    response = generated_submission_bundle.build
    expect(response.valid?).to be_truthy
    efile_submission.submission_bundle.open do |submission_bundle|
      Zip::File.open(submission_bundle.path) do |zipfile|
        zipfile.entries.each do |submission_bundle_file|
          approved_submission_bundle_file_path = File.join(approved_submission_bundle_path, submission_bundle_file.name)
          expect(File.exist?(approved_submission_bundle_file_path)).to be_truthy

          generated_xml = Nokogiri::XML(submission_bundle_file.get_input_stream.read)
          generated_xml.remove_namespaces!
          approved_xml = Nokogiri::XML(File.open(approved_submission_bundle_file_path))
          approved_xml.remove_namespaces!

          ignore_list = ['IPAddress', 'IPTs', 'DeviceId', 'TotActiveTimePrepSubmissionTs', 'TotalPreparationSubmissionTs', 'ReturnTs']
          expect(generated_xml).to match_xml(approved_xml, ignore_list)
        end
      end
    end
  end
end