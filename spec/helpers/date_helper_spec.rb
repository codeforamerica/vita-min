require "rails_helper"

describe DateHelper do
  describe '#next_avaliable_date' do
    let(:date) { next_available_date(time) }
    context "when it is before 5pm and the next day is a valid day" do
      # 4pm Tuesday
      let(:time) { DateTime.new(2024, 4, 16, 15, 0, 0)}
      it "is valid and saves the intake with the next day" do
        expect(date).to eq(DateTime.new(2024, 4, 17))
      end
    end

    context "when it is before 5pm and the next day is a holiday" do
      # 4pm christmas eve
      let(:time) { DateTime.new(2024, 12, 24, 15, 0, 0)}
      it "is valid and saves the intake with a date after the holiday" do
        expect(date).to eq(DateTime.new(2024, 12, 26))
      end
    end

    context "when it is before 5pm and the next day is saturday" do
      # 4pm friday
      let(:time) { DateTime.new(2024, 4, 19, 15, 0, 0)}
      it "is valid and saves the intake with a date after the holiday" do
        expect(date).to eq(DateTime.new(2024, 4, 22))
      end
    end

    context "when it is after 5pm and the next two days are valid" do
      # 5:30pm Tuesday
      let(:time) { DateTime.new(2024, 4, 16, 17, 30, 0)}
      it "is valid and saves the intake with a date 2 business days later" do
        expect(date).to eq(DateTime.new(2024, 4, 18))
      end
    end
  end
end
