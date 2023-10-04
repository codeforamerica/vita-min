module Efile
  class ValueAccessTracker
    attr_reader :include_source

    def initialize(include_source: false)
      @include_source = include_source
    end

    def with_tracking
      @accesses = Set.new
      result = yield
      [result, @accesses]
    ensure
      @accesses = nil
    end

    def track(line_id)
      @accesses << line_id if @accesses
    end
  end
end
