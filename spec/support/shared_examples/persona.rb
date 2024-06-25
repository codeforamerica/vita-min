shared_examples :persona do
  let(:approved_output_path) { 'spec/personas/approved_output' }
  let(:approved_pdf_path) { "#{approved_output_path}/#{tax_year}/#{state_code}/#{persona_name}_return.pdf" }
  let(:approved_submission_bundle_path) { "#{approved_output_path}/#{tax_year}/#{state_code}/#{persona_name}_return_xmls" }
  let(:intake) { create persona_name }

  let(:efile_submission) { create :efile_submission, :accepted, :for_state, data_source: intake }
  let!(:initial_efile_device_info) { create :state_file_efile_device_info, :filled, :initial_creation, updated_at: Time.now - 1.minute, intake: intake }
  let!(:submission_efile_device_info) { create :state_file_efile_device_info, :filled, :submission, intake: intake }

  let(:generated_pdf) { efile_submission.generate_filing_pdf }
  let(:generated_pdf_fields) { PdfForms.new.get_fields(generated_pdf) }
  let(:generated_pdf_fields_hash) { generated_pdf_fields.to_h { |field| [field.name, field.value] } }
  let(:generated_submission_bundle) { SubmissionBundle.new(efile_submission) }

  let(:approved_pdf_fields) { PdfForms.new.get_fields(File.open(approved_pdf_path)) }
  let(:approved_pdf_fields_hash) { approved_pdf_fields.to_h { |field| [field.name, field.value] } }

  it 'generates identical filing PDF to approved output' do
    expect(approved_pdf_fields_hash).to match(generated_pdf_fields_hash)
  end

  it 'generates identical submission bundle to approved output' do
    efile_submission.update(irs_submission_id: submission_id)
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
