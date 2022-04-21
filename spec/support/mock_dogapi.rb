module MockDogapi
  extend ActiveSupport::Concern

  included do
    before do
      @mock_dogapi = instance_double(Dogapi::Client, emit_point: nil)
      allow(Dogapi::Client).to receive(:new).and_return(@mock_dogapi)
      DatadogApi.instance_variable_set("@synchronous", true)
    end

    after do
      DatadogApi.instance_variable_set("@dogapi_client", nil)
      DatadogApi.instance_variable_set("@synchronous", false)
    end
  end

  def enable_datadog_and_stub_emit_point
    DatadogApi.configure do |c|
      allow(c).to receive(:enabled).and_return(true)
    end

    @emit_point_params = []
    allow(@mock_dogapi).to receive(:emit_point) do |*params|
      @emit_point_params << params
    end
  end
end
