class Intake14446PdfJob < ApplicationJob
  def perform(intake, filename)
    intake.create_14446_document(filename)
  end
end