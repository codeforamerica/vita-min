require 'rails_helper'

describe Routes::CtcDomain do
  before do
    allow(Rails.application.config).to receive(:ctc_url).and_return('http://ctc.example.com/')
  end

  let(:subject) { Routes::CtcDomain.new }

  describe "#matches?" do
    it 'returns true if the request host is a ctc domain' do
      expect(subject.matches?(instance_double(ActionDispatch::Request, host: "ctc.example.com")))
        .to be_truthy
      expect(subject.matches?(instance_double(ActionDispatch::Request, host: "anything-else.example.com")))
        .to be_falsey
    end
  end
end
