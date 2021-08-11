class NullForm < QuestionsForm
  def self.existing_attributes(*_args)
    {}
  end

  def save
    true
  end
end
