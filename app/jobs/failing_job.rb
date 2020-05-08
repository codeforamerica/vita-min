class FailingJob < ApplicationJob
  queue_as :default

  def perform(test_data)
    with_raven_context({test_data: test_data}, "from FAILING JOB, ignore plz") do
      raise "forced test exception with context"
    end
  end
end
