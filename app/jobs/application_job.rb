class ApplicationJob < ActiveJob::Base
  include ConsolidatedTraceHelper

end
