require 'rails_helper'

class ExampleDateAccessor
  include DateAccessible
  attr_accessor :read_date, :write_date, :readwrite_date,
                :readwrite_multi_date, :readwrite_multi_second_date

  date_reader :read_date
  date_writer :write_date

  date_accessor :readwrite_date
  date_accessor :readwrite_multi_date, :readwrite_multi_second_date
end

RSpec.describe DateAccessible do
  subject { ExampleDateAccessor.new }

  describe '#date_accessor' do
    it 'should create readers & writers for a single property' do
      expect(subject).to respond_to(:readwrite_date_day)
      expect(subject).to respond_to(:readwrite_date_month)
      expect(subject).to respond_to(:readwrite_date_year)

      expect(subject).to respond_to(:readwrite_date_day=)
      expect(subject).to respond_to(:readwrite_date_month=)
      expect(subject).to respond_to(:readwrite_date_year=)
    end

    it 'should create readers & writers for multiple property' do
      expect(subject).to respond_to(:readwrite_multi_date_day)
      expect(subject).to respond_to(:readwrite_multi_date_month)
      expect(subject).to respond_to(:readwrite_multi_date_year)

      expect(subject).to respond_to(:readwrite_multi_date_day=)
      expect(subject).to respond_to(:readwrite_multi_date_month=)
      expect(subject).to respond_to(:readwrite_multi_date_year=)

      expect(subject).to respond_to(:readwrite_multi_second_date_day)
      expect(subject).to respond_to(:readwrite_multi_second_date_month)
      expect(subject).to respond_to(:readwrite_multi_second_date_year)

      expect(subject).to respond_to(:readwrite_multi_second_date_day=)
      expect(subject).to respond_to(:readwrite_multi_second_date_month=)
      expect(subject).to respond_to(:readwrite_multi_second_date_year=)
    end
  end

  describe "#date_writer" do
    it 'should allow the use of the a _day writer' do
      expect(subject).to respond_to(:write_date_day=)

      expect(subject.write_date).to be_nil

      subject.write_date_day = 12
      expect(subject.write_date).to eq(Date.new.change(day: 12))
    end

    it 'should allow the use of the a _month writer' do
      expect(subject).to respond_to(:write_date_month=)

      expect(subject.write_date).to be_nil

      subject.write_date_month = 5
      expect(subject.write_date).to eq(Date.new.change(month: 5))
    end

    it 'should allow the use of the a _year writer' do
      expect(subject).to respond_to(:write_date_year=)

      expect(subject.write_date).to be_nil

      subject.write_date_year = 1990
      expect(subject.write_date).to eq(Date.new.change(year: 1990))
    end

    it 'should have garbage-resistant writers' do
      subject.write_date_day = ''

      expect(subject.write_date).to be_nil

      subject.write_date_day = "foo"

      expect(subject.write_date).to be_nil

      subject.write_date_day = 0

      expect(subject.write_date).to be_nil
    end

    it 'should not change the value when writing garbage' do
      subject.write_date = Date.new(1990, 5, 12)

      subject.write_date_day = "foo"

      expect(subject.write_date).to eq(Date.new(1990, 5, 12))
    end
  end

  describe "#date_reader" do
    it 'should allow the use of the a _day reader' do
      expect(subject).to respond_to(:read_date_day)

      expect(subject.read_date_day).to be_nil

      subject.read_date = Date.new(1990, 5, 12)

      expect(subject.read_date_day).to eq(12)
    end

    it 'should allow the use of the a _month reader' do
      expect(subject).to respond_to(:read_date_month)

      expect(subject.read_date_month).to be_nil

      subject.read_date = Date.new(1990, 5, 12)

      expect(subject.read_date_month).to eq(5)
    end

    it 'should allow the use of the a _year reader' do
      expect(subject).to respond_to(:read_date_year)

      expect(subject.read_date_year).to be_nil

      subject.read_date = Date.new(1990, 5, 12)

      expect(subject.read_date_year).to eq(1990)
    end
  end

  describe "#change_date_property" do
    it 'should create a date if one does not exist'do
      expect(subject.readwrite_date).to be_nil

      subject.send(:change_date_property, :readwrite_date, day: 12)

      expect(subject.readwrite_date.day).to eq(12)
    end

    it 'should only change the date fragements specified' do
      subject.readwrite_date = Date.new(1990, 5, 28)
      expect(subject.readwrite_date).to eq(Date.new(1990, 5, 28))

      subject.send(:change_date_property, :readwrite_date, day: 12)

      expect(subject.readwrite_date.day).to eq(12)
      expect(subject.readwrite_date.month).to eq(5)
      expect(subject.readwrite_date.year).to eq(1990)
    end

    it 'should not consider fragments other than month, day, or year' do
      subject.readwrite_date = Date.new(1990, 5, 12)
      expect(subject.readwrite_date).to eq(Date.new(1990, 5, 12))

      subject.send(:change_date_property, :readwrite_date, foo: "bar")

      expect(subject.readwrite_date.day).to eq(12)
      expect(subject.readwrite_date.month).to eq(5)
      expect(subject.readwrite_date.year).to eq(1990)
    end
  end
end
