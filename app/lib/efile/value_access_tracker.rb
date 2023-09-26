module Efile
  class ValueAccessTracker
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
