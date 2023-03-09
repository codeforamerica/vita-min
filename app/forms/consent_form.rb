class ConsentForm < QuestionsForm
  include DateHelper
  set_attributes_for(
    :intake,
    :primary_first_name,
    :primary_last_name,
  )

  validates_presence_of :primary_first_name
  validates_presence_of :primary_last_name

  def save
    intake.update(attributes_for(:intake))
  end
end
