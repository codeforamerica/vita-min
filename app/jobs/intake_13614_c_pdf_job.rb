class Intake13614CPdfJob < ApplicationJob
  def perform(intake, filename)
    intake.create_13614c_document(filename)
  end
end