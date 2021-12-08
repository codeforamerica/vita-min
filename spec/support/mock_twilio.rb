module MockTwilio
  extend ActiveSupport::Concern

  included do
    around(:each) do |example|
      TwilioService.class_variable_set(:@@_client, nil)
      example.run
      TwilioService.class_variable_set(:@@_client, nil)
    end

    before do
      allow(Twilio::REST::Client).to receive(:new).and_return(FakeTwilioClient.new)
    end
  end
end
