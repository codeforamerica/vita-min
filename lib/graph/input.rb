class Graph::Input
  attr_accessor :name, :attribute_name, :validator

  def initialize(name:, attribute_name: nil, validator:)
    @name = name
    @attribute_name = attribute_name
    @validator = validator
  end

  def call(val)
    self.validator.call(val)
  rescue NoMatchingPatternError
    raise Graph::ValidationError
  end
end
