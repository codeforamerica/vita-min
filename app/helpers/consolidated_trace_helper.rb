## Severity
#
# provides constants indicating severity
module Severity
  DEBUG = 'debug'.freeze
  INFO = 'info'.freeze
  WARN = 'warn'.freeze
  ERROR = 'error'.freeze
  FATAL = 'fatal'.freeze
  UNKNOWN = 'unknown'.freeze
end

## ConsolidatedTraceHelper
#
# provides functions for recording error information for traceability. submits
# to both the rails logger and to Raven
module ConsolidatedTraceHelper

  def unwind_extra_context(extra_context = {}, severity = Severity::UNKNOWN)
    last_context = Raven.context.extra
    Raven.extra_context(extra_context.merge(level: severity))

    yield

    Raven.context.extra = last_context
  end

  ## adds context to the raven extra context
  def with_raven_context(extra_context={}, message = nil, severity = Severity::UNKNOWN)
    yield
  rescue => exception
    trace_message = log_body(message || exception.message, extra_context)
    logger&.send(severity, trace_message)

    unwind_extra_context(extra_context, severity) do
      raise exception, trace_message
    end
  end

  ## generic trace method providing severity options
  def trace(message, extra_context = {}, severity = Severity::UNKNOWN)
    trace_message = log_body(message, extra_context)
    logger&.send(severity, trace_message)

    unwind_extra_context(extra_context, severity) do
      Raven.capture_message(trace_message)
    end
  end

  # creates a log body
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

  def intake_context(intake)
    {
        name: intake.preferred_name,
        email: intake.email_address,
        phone: intake.phone_number,
        intake_id: intake.id,
        zendesk_ticket_id: intake.intake_ticket_id,
        zendesk_requester_id: intake.intake_ticket_requester_id
    }
  end

  def trace_debug(message, extra_context = {})
    trace(message, extra_context, Severity::DEBUG)
  end

  def trace_info(message, extra_context = {})
    trace(message, extra_context, Severity::INFO)
  end

  def trace_warning(message, extra_context = {})
    trace(message, extra_context, Severity::WARN)
  end

  def trace_error(message, extra_context = {})
    trace(message, extra_context, Severity::ERROR)
  end

  def trace_fatal(message, extra_context = {})
    trace(message, extra_context, Severity::FATAL)
  end

  def trace_unknown(message, extra_context = {})
    trace(message, extra_context, Severity::UNKNOWN)
  end

  private

  def local_trace
    Thread.current
        .backtrace
        .filter { |line| !line.include? 'consolidated_trace' }
        .slice(0, 5)
        .join("\n")
  end
end
