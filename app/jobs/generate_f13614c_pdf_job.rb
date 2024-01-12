class GenerateF13614cPdfJob < ApplicationJob
  def perform(intake_id, filename = nil)
    intake = Intake.find(intake_id)
    intake.update_or_create_13614c_document(filename)
    #SPLITTING THE DOC FROM PREVIEW SEEMS TO HAVE ERASED ITS FIELDS
  end

  def priority
    PRIORITY_HIGH
  end
end