class ApplicationJob < ActiveJob::Base
  include ConsolidatedTraceHelper

  def job_object_id
    # This assumes most of our jobs use positional arguments
    # where the id or thing the job is working on is the first
    # argument. Subclasses are free to override `job_object_id`
    # to look elsewhere in the arguments.
    # If we eventually end up using keyword arguments more often this could
    # be extended to look at the first keyword argument as well.
    if arguments.first.is_a?(Integer)
      arguments.first
    elsif arguments.first.respond_to?(:id)
      arguments.first.id
    end
  end

  def serialize
    super.merge("job_object_id" => job_object_id)
  end
end
