class Intake14446PdfJob < ApplicationJob
  def perform(intake, filename)
    intake.update_or_create_14446_document(filename)
  end
end