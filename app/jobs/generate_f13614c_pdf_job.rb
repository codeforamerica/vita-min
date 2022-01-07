class GenerateF13614cPdfJob < ApplicationJob
  def perform(intake_id, filename = nil)
    intake = Intake.find(intake_id)
    intake.update_or_create_13614c_document(filename)
  end
end