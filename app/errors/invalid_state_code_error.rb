
class InvalidStateCodeError < StandardError
  def initialize(code)
    @code = code
    super("Invalid state code: #{code}")
  end
end