class NullForm < QuestionsForm
  def self.existing_attributes(*_args)
    {}
  end

  def save
    true
  end

  def self.from_record(record)
    new(nil, {})
  end
end
