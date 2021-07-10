class NullForm < QuestionsForm
  def self.existing_attributes(_)
    {}
  end

  def save
    true
  end
end