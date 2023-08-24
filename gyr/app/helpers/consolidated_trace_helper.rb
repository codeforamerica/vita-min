##
# provides functions for recording error information for traceability. submits
# to both the rails logger and to Sentry.
module ConsolidatedTraceHelper

  ##
  # provides constants indicating severity
  # the strings associated with the constants match the method names and
  # severity in `logger.rb` for ease of programmability
  module Severity
    DEBUG = 'debug'.freeze
    INFO = 'info'.freeze
    WARN = 'warn'.freeze
    ERROR = 'error'.freeze
    FATAL = 'fatal'.freeze
    UNKNOWN = 'unknown'.freeze
  end

  ##
  # when wrapped around a block of code, this will add the included
  # `extra_context` and `severity` (as `:level`) to the Sentry context, then restore
  # the original context after the block executes.
  def unwind_extra_context(extra_context = {}, severity = Severity::UNKNOWN)
    Sentry.with_scope do |scope|
      scope.set_extras(extra_context.merge(level: severity))
      yield
    end
  end

  ##
  # adds extra context, a message, and a severity (as `:level`) to the Raven
  # context. the extra context is added if and only if an exception occurs
  # in the block.
  #
  # this mainly supports the ActiveJobs included in this application, but can
  # be used anywhere.
  #
  # === Example
  #
  #     with_raven_context({ticket_id: intake.intake_ticket_id, status: intake.status},
  #                        "ClassFile is doing something risky",
  #                        Severity::WARN) do
  #       risky_thing.go()
  #     end
  #
  def with_raven_context(extra_context={}, message = nil, severity = Severity::ERROR)
    yield
  rescue => exception
    trace_message = log_body(message || exception.message, extra_context)
    Rails.logger.send(severity, trace_message)

    unwind_extra_context(extra_context, severity) do
      raise exception, trace_message
    end
  end

  ##
  # given an intake, provides consistent context using the fields
  # that are most likely to be needed to isolate a problem
  def intake_context(intake)
    {
      intake_id: intake.id,
    }
  end

  private

  ##
  # creates a log body with a message, inspected attributes,
  # and a backtrace including the output from `local_trace`
  def log_body(msg, attrs)
    <<~MSGBODY
      #{msg}
      MESSAGE INCLUDED:
      #{attrs.inspect}
      RELEVANT STACK:
      #{local_trace}
      ----
    MSGBODY
  end

  ##
  # generates five lines of backtrace, stripping out
  # this module's cruft
  def local_trace
    Thread.current
          .backtrace
          .filter { |line| !line.include? 'consolidated_trace' }
          .slice(0, 5)
          .join("\n")
  end
end
