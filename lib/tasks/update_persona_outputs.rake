STATE_PERSONAS = {
  az: [:johnny, :leslie, :martha, :rory],
  ny: [:javier],
}

namespace :update_persona_outputs do
  desc "Update the PDF output of all personas for a state"
  task generate_pdfs: :environment do
    STATE_PERSONAS.each do |us_state, personas|
      personas.each do |persona_name|
        intake = FactoryBot.create(persona_name, federal_submission_id: "1016422024018atw000x")
        efile_submission = FactoryBot.create(:efile_submission, :accepted, :for_state, data_source: intake)
        generated_pdf = efile_submission.generate_filing_pdf
        path = "spec/fixtures/state_file/persona_approved_outputs/2023/#{us_state}/#{persona_name}_return.pdf"
        File.write(path, generated_pdf.read)
      end
    end
  end
end
