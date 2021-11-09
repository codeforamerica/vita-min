module MockDogapi
  extend ActiveSupport::Concern

  included do
    before do
      @mock_dogapi = instance_double(Dogapi::Client, emit_point: nil)
      allow(Dogapi::Client).to receive(:new).and_return(@mock_dogapi)
    end

    after do
      DatadogApi.instance_variable_set("@dogapi_client", nil)
    end
  end
end
