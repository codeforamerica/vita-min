module Efile
  class Error
    attr_accessor :code, :category, :severity, :message
    def initialize(code: nil, message: nil, category: nil, severity: nil)
      @code = code
      @message = message
      @category = category
      @severity = severity
    end
  end
end