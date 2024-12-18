require 'rails_helper'

class ExampleNcResidency
  attr_accessor :residence_county

  include NcResidenceCountyConcern
end

RSpec.describe NcResidenceCountyConcern do
  subject do
    ExampleNcResidency.new.tap do |example|
      example.residence_county = "001"
    end
  end

  describe "#residence_county_name" do
    it "should return the correct county name" do
      expect(subject.residence_county_name).to eq "Alamance"
    end
  end

  describe "#residence_county_hash" do
    it 'should return the correct hash' do
      expect(subject.residence_county_hash).to eq(
        {county_code: "001", county_name: "Alamance"}
      )
    end
  end
end
