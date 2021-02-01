class IntakePdfJob < ApplicationJob
  def perform(intake_id, filename)
    intake = Intake.find(intake_id)
    intake.create_intake_document(filename)
  end
end