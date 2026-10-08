require 'rails_helper'

describe Routes::CtcDomain do
  let(:subject) { Routes::CtcDomain.new }

  describe "#matches?" do
    it 'returns true for the legacy getctc.org domain and its subdomains' do
      expect(subject.matches?(instance_double(ActionDispatch::Request, host: "getctc.org")))
        .to be_truthy
      expect(subject.matches?(instance_double(ActionDispatch::Request, host: "www.getctc.org")))
        .to be_truthy
    end

    it 'returns false for other domains' do
      expect(subject.matches?(instance_double(ActionDispatch::Request, host: "www.getyourrefund.org")))
        .to be_falsey
      expect(subject.matches?(instance_double(ActionDispatch::Request, host: "anything-else.example.com")))
        .to be_falsey
    end

    it 'does not match a domain that merely ends in the same characters' do
      expect(subject.matches?(instance_double(ActionDispatch::Request, host: "notgetctc.org")))
        .to be_falsey
    end
  end
end
