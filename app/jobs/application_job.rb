class ApplicationJob < ActiveJob::Base

  def with_raven_context(extra)
    yield
  rescue => exception
    Raven.capture_exception(exception, extra: extra)
  end
end
