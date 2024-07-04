shared_examples :persona do
  let(:approved_output_path) { 'spec/personas/approved_output' }

  # fake fed submission id will be ignored in comparison
  let(:intake) { create persona_name, federal_submission_id: "1016422024018atw000x" }
  let(:efile_submission) { create :efile_submission, :accepted, :for_state, data_source: intake }

  it 'generates identical filing PDF to approved output' do
    generated_pdf = efile_submission.generate_filing_pdf
    generated_pdf_hash = PdfForms.new.get_fields(generated_pdf).to_h { |field| [field.name, field.value] }

    approved_pdf_path = "#{approved_output_path}/#{tax_year}/#{state_code}/#{persona_name}_return.pdf"
    approved_pdf_hash = PdfForms.new.get_fields(File.open(approved_pdf_path)).to_h { |field| [field.name, field.value] }

    expect(generated_pdf_hash).to match(approved_pdf_hash)
  end

  it 'generates identical submission bundle to approved output' do
    create(:state_file_efile_device_info, :filled, :initial_creation, intake: intake)
    create(:state_file_efile_device_info, :filled, :submission, intake: intake)
    efile_submission.generate_irs_submission_id!
    response = SubmissionBundle.new(efile_submission).build
    expect(response.errors).to be_empty
    expect(response.valid?).to be true

    approved_submission_bundle_path = "#{approved_output_path}/#{tax_year}/#{state_code}/#{persona_name}_return_xmls"
    efile_submission.submission_bundle.open do |submission_bundle|
      Zip::File.open(submission_bundle.path) do |zipfile|
        zipfile.entries.each do |submission_bundle_file|
          approved_submission_bundle_file_path = File.join(approved_submission_bundle_path, submission_bundle_file.name)
          expect(File.exist?(approved_submission_bundle_file_path)).to be_truthy

          generated_xml = Nokogiri::XML(submission_bundle_file.get_input_stream.read)
          generated_xml.remove_namespaces!
          approved_xml = Nokogiri::XML(File.open(approved_submission_bundle_file_path))
          approved_xml.remove_namespaces!

          node_ignore_list = %w[TransmissionDetail ReturnTs SubmissionId IRSSubmissionId]
          attr_ignore_list = %w[documentId]
          expect(generated_xml).to match_xml(approved_xml, node_ignore_list, attr_ignore_list)
        end
      end
    end
  end
end
