RSpec.configure do |config|
  config.before(:each) do |example|
    unless example.metadata[:do_not_stub_usps]
      allow_any_instance_of(StandardizeAddressService).to receive(:build_standardized_address) do |*args|
        service = args.first
        {
          street_address: service.instance_variable_get(:@_street_address),
          city: service.instance_variable_get(:@_city),
          state: service.instance_variable_get(:@_state),
          zip_code: service.instance_variable_get(:@_zip_code),
          error_message: "",
          error_code: ""
        }
      end
    end
  end
end
