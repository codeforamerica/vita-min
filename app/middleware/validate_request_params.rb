class ValidateRequestParams
  INVALID_CHARACTERS = [
      "\u0000" # null bytes
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if has_invalid_character?(request.params.values)
      return [400, {}, ["Bad Request"]]
    end

    if request.cookies["my_session"].present? && string_contains_invalid_character?(request.cookies["my_session"])
      return [400, {}, ["Bad Request"]]
    end

    @app.call(env)
  end

  private

  def has_invalid_character?(param_values)
    param_values.any? do |value|
      check_for_invalid_characters_recursively(value)
    end
  end

  def check_for_invalid_characters_recursively(value, depth = 0)
    return false if depth > 2

    depth += 1
    if value.respond_to?(:match)
      string_contains_invalid_character?(value)
    elsif value.respond_to?(:values)
      value.values.any? do |hash_value|
        check_for_invalid_characters_recursively(hash_value, depth)
      end
    elsif value.is_a?(Array)
      value.any? do |array_value|
        check_for_invalid_characters_recursively(array_value, depth)
      end
    end
  end

  def string_contains_invalid_character?(string)
    invalid_characters_regex = Regexp.union(INVALID_CHARACTERS)

    string.match?(invalid_characters_regex)
  end
end