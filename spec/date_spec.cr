require "./spec_helper"

require "duration"

describe Date do
  it "instantiates with year/month/day" do
    date = Date.new(2026, 1, 7)

    date.year.should eq 2026
    date.month.should eq 1
    date.day.should eq 7
  end

  it "adds days" do
    date = Date.new(2026, 1, 7)

    (date + 1.calendar_day).should eq Date.new(2026, 1, 8)
    (date + 30.calendar_days).should eq Date.new(2026, 2, 6)
    (date + 1.day).should eq Date.new(2026, 1, 8)
    (date + 30.days).should eq Date.new(2026, 2, 6)
  end

  it "adds months" do
    date = Date.new(2026, 1, 7)

    (date + 1.calendar_month).should eq Date.new(2026, 2, 7)
    (date + 1.month).should eq Date.new(2026, 2, 7)
    (date + 12.months).should eq Date.new(2027, 1, 7)
  end

  it "subtracts days" do
    date = Date.new(2026, 2, 7)

    (date - 1.calendar_day).should eq Date.new(2026, 2, 6)
    (date - 30.calendar_days).should eq Date.new(2026, 1, 8)
    (date - 1.day).should eq Date.new(2026, 2, 6)
    (date - 30.days).should eq Date.new(2026, 1, 8)
  end

  it "subtracts months" do
    date = Date.new(2026, 2, 7)

    (date - 1.calendar_month).should eq Date.new(2026, 1, 7)
    (date - 1.month).should eq Date.new(2026, 1, 7)
    (date - 12.months).should eq Date.new(2025, 2, 7)
  end

  it "raises on an invalid date" do
    expect_raises ArgumentError do
      Date.new(2026, 13, 42)
    end
  end

  it "returns the day of the week using Time::DayOfWeek" do
    Date.new(2026, 1, 1).day_of_week.should eq Date::DayOfWeek::Thursday
    Date.new(2026, 1, 2).day_of_week.should eq Date::DayOfWeek::Friday
    Date.new(2026, 1, 3).day_of_week.should eq Date::DayOfWeek::Saturday
    Date.new(2026, 1, 4).day_of_week.should eq Date::DayOfWeek::Sunday
    Date.new(2026, 1, 5).day_of_week.should eq Date::DayOfWeek::Monday
    Date.new(2026, 1, 6).day_of_week.should eq Date::DayOfWeek::Tuesday
    Date.new(2026, 1, 7).day_of_week.should eq Date::DayOfWeek::Wednesday
  end

  describe "shifting to boundaries of larger units of time" do
    date = Date.new(2026, 2, 26)

    it "shifts to the beginning of the week" do
      date.at_beginning_of_week(:sunday).should eq Date.new(2026, 2, 22)
      date.at_beginning_of_week(:monday).should eq Date.new(2026, 2, 23)
    end

    it "shifts to the end of the week" do
      date.at_end_of_week(:sunday).should eq Date.new(2026, 2, 28)
      date.at_end_of_week(:monday).should eq Date.new(2026, 3, 1)
    end

    it "shifts to the beginning of the month" do
      date.at_beginning_of_month.should eq Date.new(2026, 2, 1)
    end

    it "shifts to the end of the month" do
      date.at_end_of_month.should eq Date.new(2026, 2, 28)
      # Leap year
      Date.new(2024, 2, 26).at_end_of_month.should eq Date.new(2024, 2, 29)
    end

    it "shifts to the beginning of the year" do
      date.at_beginning_of_year.should eq Date.new(2026, 1, 1)
    end

    it "shifts to the end of the year" do
      date.at_end_of_year.should eq Date.new(2026, 12, 31)
    end
  end

  it "converts Times to Dates" do
    Time.local(2026, 1, 7, 12, 34, 56).to_date.should eq Date.new(2026, 1, 7)
  end

  it "iterates between dates" do
    count = 0
    (Date.new(2026, 1, 1)...Date.new(2027, 1, 1)).each do |date|
      count += 1
    end
    count.should eq 365

    count = 0
    Date.new(2027, 1, 1).step to: Date.new(2026, 1, 1), by: -1.calendar_day, exclusive: true do |date|
      count += 1
    end
    count.should eq 365
  end

  it "parses dates" do
    Date.parse("2026-01-07").should eq Date.new(2026, 1, 7)
  end

  it "raises an ArgumentError when the date is invalid" do
    [
      "2026-02-29", # 2026 is not a leap year
      "2026-00-01", # There is no 0th month
      "2026-13-01", # There is no 13th month
      "Nope",
    ].each do |date_string|
      expect_raises ArgumentError do
        Date.parse date_string
      end
    end
  end
end
