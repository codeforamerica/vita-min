# use this to verify that sentry is seeing what
# we want it to see


namespace :test do
  desc "dispatch an exception from a background job"
  task dispatch_exception: [:environment] do
    class DoAnExceptionalJob < ApplicationJob
      def perform(fake_id)
        with_raven_context({ticket_id: fake_id}) do
          raise "hell"
        end
      end
    end
    DoAnExceptionalJob.perform_now('from test:dispatch_exception with love')
  end
end
