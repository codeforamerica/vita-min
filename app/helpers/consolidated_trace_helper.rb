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

  ## generic trace method providing severity options
  def trace(message, attributes = {}, severity = Severity::UNKNOWN)
    # send message to rails logger at the appropriate severity
    stack_trace = Thread.current
                        .backtrace
                        .filter { |line| !line.include? 'consolidated_trace' }
                        .slice(0, 5)
                        .join("\n")
    logger&.send(severity, log_body(message, attributes, stack_trace))
    Raven.capture_message(message, { extra: attributes, severity: severity })
  end

  # creates a log body
  def log_body(msg, attrs, st)
    <<~MSGBODY
      #{msg}
      MESSAGE INCLUDED:
      #{attrs.inspect}
      RELEVANT STACK:
      #{st}
      ----
    MSGBODY
  end

  def trace_debug(message, attributes = {})
    trace(message, attributes, Severity::DEBUG)
  end

  def trace_info(message, attributes = {})
    trace(message, attributes, Severity::INFO)
  end

  def trace_warning(message, attributes = {})
    trace(message, attributes, Severity::WARN)
  end

  def trace_error(message, attributes = {})
    trace(message, attributes, Severity::ERROR)
  end

  def trace_fatal(message, attributes = {})
    trace(message, attributes, Severity::FATAL)
  end

  def trace_unknown(message, attributes = {})
    trace(message, attributes, Severity::UNKNOWN)
  end
end