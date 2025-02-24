require 'rails_helper'

RSpec.describe DateAccessible do
  let(:year) { Rails.configuration.statefile_current_tax_year }
  let(:month) { 2 }
  let(:day) { 1 }
  let(:expiration_date) { Date.new(year, month, day) }
  subject { create(:state_id, expiration_date: expiration_date) }

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
    end

    context "with a date set" do
      context "and an invalid submitted value to update" do
        it "is not set" do
          subject.expiration_date_day = 21
          subject.expiration_date_year = nil
          subject.valid?
          expect(subject.expiration_date).to eq(expiration_date)
        end
      end
    end
  end

  describe "#date_reader" do
    context "when the date is not set" do
      let(:expiration_date) { nil }

      it 'should allow the use of the a _day reader' do
        expect(subject).to respond_to(:expiration_date_day)
        expect(subject.expiration_date_day).to be_nil
      end

      it 'should allow the use of the a _month reader' do
        expect(subject).to respond_to(:expiration_date_month)
        expect(subject.expiration_date_month).to be_nil
      end

      it 'should allow the use of the a _year reader' do
        expect(subject).to respond_to(:expiration_date_year)
        expect(subject.expiration_date_year).to be_nil
      end
    end

    context "when the date is set" do
      it 'should allow the use of the a _day reader' do
        expect(subject).to respond_to(:expiration_date_day)
        expect(subject.expiration_date_day).to eq(day)
      end

      it 'should allow the use of the a _month reader' do
        expect(subject).to respond_to(:expiration_date_month)
        expect(subject.expiration_date_month).to eq(month)
      end

      it 'should allow the use of the a _year reader' do
        expect(subject).to respond_to(:expiration_date_year)
        expect(subject.expiration_date_year).to eq(year)
      end
    end
  end
end
