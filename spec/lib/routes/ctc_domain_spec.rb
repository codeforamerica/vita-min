require 'rails_helper'

describe Routes::CtcDomain do
  let(:ctc_localhost) { instance_double(ActionDispatch::Request, host: "ctc.localhost") }
  let(:ctc_demo_www) { instance_double(ActionDispatch::Request, host: "www.ctc.demo.getyourrefund.org") }
  let(:root_demo) { instance_double(ActionDispatch::Request, host: "demo.getyourrefund.org") }
  let(:root_localhost) { instance_double(ActionDispatch::Request, host: "localhost") }

  let(:subject) { Routes::CtcDomain.new }

  describe "#matches?" do
    it 'returns true if the request host has a ctc subdomain of an approved domain' do
      expect(subject.matches?(ctc_localhost)).to be_truthy
      expect(subject.matches?(ctc_demo_www)).to be_truthy
      expect(subject.matches?(root_demo)).to be_falsey
      expect(subject.matches?(root_localhost)).to be_falsey
    end
  end
end