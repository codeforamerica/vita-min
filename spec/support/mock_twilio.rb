module MockTwilio
  extend ActiveSupport::Concern

  included do
    before do
      allow(Twilio::REST::Client).to receive(:new).and_return(FakeTwilioClient.new)
    end
  end
end
