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
# provides functions for recording error information for traceability. submits
# to both the rails logger and to Raven (Sentry).
module ConsolidatedTraceHelper

  ##
  # when wrapped around a block of code, this will add the included
  # `extra_context` and `severity` (as `:level`) to the Raven context, then restore
  # the original context after the block executes.
  def unwind_extra_context(extra_context = {}, severity = Severity::UNKNOWN)
    last_context = Raven.context.extra
    Raven.extra_context(extra_context.merge(level: severity))

    yield

    Raven.context.extra = last_context
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
    logger&.send(severity, trace_message)

    unwind_extra_context(extra_context, severity) do
      raise exception, trace_message
    end
  end

  ##
  # generic trace method providing severity options, and reporting out
  # to both Raven (Sentry) and the defined logger. the format of the body of the
  # message can be found in the `log_body` method.
  #
  # *NOTE*: if no logger is defined, it will be unhappy.
  #
  # === Example
  #
  #     if bad_thing.has_happened?
  #       trace('not critical, but bad thing should not happen',
  #             {bad_thing_id: bad_thing.id, bad_thing_args: **args},
  #             Severity::DEBUG)
  #
  def trace(message, extra_context = {}, severity = Severity::UNKNOWN)
    trace_message = log_body(message, extra_context)
    logger&.send(severity, trace_message)

    unwind_extra_context(extra_context, severity) do
      Raven.capture_message(trace_message)
    end
  end

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
  # given an intake, provides consistent context using the fields
  # that are most likely to be needed to isolate a problem
  def intake_context(intake)
    {
        name: intake.preferred_name,
        email: intake.email_address,
        phone: intake.phone_number,
        intake_id: intake.id,
        ticket_id: intake.intake_ticket_id,
        requester_id: intake.intake_ticket_requester_id
    }
  end

  ##
  # trace with DEBUG severity
  def trace_debug(message, extra_context = {})
    trace(message, extra_context, Severity::DEBUG)
  end

  ##
  # trace with INFO severity
  def trace_info(message, extra_context = {})
    trace(message, extra_context, Severity::INFO)
  end

  ##
  # trace with WARN severity
  def trace_warning(message, extra_context = {})
    trace(message, extra_context, Severity::WARN)
  end

  ##
  # trace with ERROR severity
  def trace_error(message, extra_context = {})
    trace(message, extra_context, Severity::ERROR)
  end

  ##
  # trace with FATAL severity
  def trace_fatal(message, extra_context = {})
    trace(message, extra_context, Severity::FATAL)
  end

  ##
  # trace with UNKNOWN severity
  def trace_unknown(message, extra_context = {})
    trace(message, extra_context, Severity::UNKNOWN)
  end

  private

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
