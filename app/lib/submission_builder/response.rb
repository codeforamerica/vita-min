module SubmissionBuilder
  class Response
    attr_accessor :errors, :document
    def initialize(errors:, document:)
      @errors = errors
      @document = document
    end

    def valid?
      @errors.empty?
    end
  end
end