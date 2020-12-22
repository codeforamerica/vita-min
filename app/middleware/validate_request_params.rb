class ValidateRequestParams
  INVALID_CHARACTERS = [
      "\u0000" # null bytes
  ].freeze

  INVALID_CHARS_REGEX = Regexp.union(INVALID_CHARACTERS).freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    return bad_request_response if includes_invalid_character?(request.params.values) || includes_invalid_character?(request.cookies["_vita_min_session"])

    @app.call(env)
  end

  private

  def includes_invalid_character?(param_values)
    return false unless param_values.present?

    check_for_invalid_characters_recursively(param_values)
  end

  def check_for_invalid_characters_recursively(value, depth = 0)
    return false if depth > 3 || value.nil?
    return contains_invalid_character?(value) if value.respond_to?(:match?)

    depth += 1
    value = value.values if value.respond_to?(:values)
    return value.map.any? { |val| check_for_invalid_characters_recursively(val, depth) }
  end

  def bad_request_response
    [400, {}, ["Bad Request"]]
  end

  def contains_invalid_character?(value)
    value.match?(INVALID_CHARS_REGEX)
  end
end