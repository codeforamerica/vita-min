# === When to run this task ===
# If you are updating the AZ pdf output, the `persona_spec.rb` should fail.
# Run this task to update the output pdf fixtures with your new changes.
#
# ~~~IF THE PDF IS CHANGING IN A MEANINGFUL WAY (aka you are adding or changing a value)~~~
# have a PM or whoever is acceptance testing your story look at the new PDF fixtures generated by this task.
# You can point them to the PR, which lets you view PDFs if you click "..." -> "View file"
# ~~~EITHER WAY~~~ look at the new fixtures yourself before committing them. Even if there are
# no "meaningful" changes (i.e. a value changes from nil to "") you should make sure it doesn't look any different.
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
