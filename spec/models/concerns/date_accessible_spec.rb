require 'rails_helper'

RSpec.describe DateAccessible do
  let(:year) { Rails.configuration.statefile_current_tax_year }
  subject { create(:state_id) }

  describe '#date_accessor' do
    it 'should create readers & writers for a single property' do
      expect(subject).to respond_to(:expiration_date_day)
      expect(subject).to respond_to(:expiration_date_month)
      expect(subject).to respond_to(:expiration_date_year)

      expect(subject).to respond_to(:expiration_date_day=)
      expect(subject).to respond_to(:expiration_date_month=)
      expect(subject).to respond_to(:expiration_date_year=)
    end

    it 'should create readers & writers for multiple property' do
      expect(subject).to respond_to(:expiration_date_day)
      expect(subject).to respond_to(:expiration_date_month)
      expect(subject).to respond_to(:expiration_date_year)

      expect(subject).to respond_to(:expiration_date_day=)
      expect(subject).to respond_to(:expiration_date_month=)
      expect(subject).to respond_to(:expiration_date_year=)

      expect(subject).to respond_to(:issue_date_day)
      expect(subject).to respond_to(:issue_date_month)
      expect(subject).to respond_to(:issue_date_year)

      expect(subject).to respond_to(:issue_date_day=)
      expect(subject).to respond_to(:issue_date_month=)
      expect(subject).to respond_to(:issue_date_year=)
    end
  end

  describe "#date_writer" do
    it 'should allow the use of the a writer for all values' do
      subject.expiration_date = nil
      subject.expiration_date_day = 1
      subject.expiration_date_month = 2
      subject.expiration_date_year = year
      subject.valid?
      expect(subject.expiration_date).to eq(Date.new(year, 2, 1))

      subject.expiration_date_day = 21
      subject.expiration_date_year = nil
      subject.valid?
      expect(subject.expiration_date).to eq(Date.new(year, 2, 1))
    end
  end

  describe "#date_reader" do
    it 'should allow the use of the a _day reader' do
      expect(subject).to respond_to(:expiration_date_day)

      expect(subject.expiration_date_day).to be_nil

      subject.expiration_date_day = 12
      subject.expiration_date_month = 2
      subject.expiration_date_year = year
      subject.valid?

      expect(subject.expiration_date_day).to eq(12)
    end

    it 'should allow the use of the a _month reader' do
      expect(subject).to respond_to(:expiration_date_month)

      expect(subject.expiration_date_month).to be_nil

      subject.expiration_date_day = 1
      subject.expiration_date_month = 5
      subject.expiration_date_year = year
      subject.valid?

      expect(subject.expiration_date_month).to eq(5)
    end

    it 'should allow the use of the a _year reader' do
      expect(subject).to respond_to(:expiration_date_year)

      expect(subject.expiration_date_year).to be_nil

      subject.expiration_date_day = 1
      subject.expiration_date_month = 2
      subject.expiration_date_year = year
      subject.valid?

      expect(subject.expiration_date_year).to eq(year)
    end
  end
end
