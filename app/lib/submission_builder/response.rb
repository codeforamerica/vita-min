module SubmissionBuilder
  class Response
    attr_accessor :errors, :document, :root_node
    def initialize(errors: [], document:, root_node:)
      @errors = errors
      @document = document
      @root_node = root_node
    end

    def valid?
      @errors.empty?
    end

    def as_fragment
      document.at(root_node)
    end
  end
end