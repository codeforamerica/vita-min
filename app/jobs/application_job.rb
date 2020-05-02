class ApplicationJob < ActiveJob::Base

  def with_raven_context(extra_context={})
    yield
  rescue => exception
    Raven.extra_context(extra_context)
    raise exception
  end

end
