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

  describe "formatting as a string" do
    it "converts into a YYYY-MM-DD string by default" do
      Date.new(2026, 1, 2).to_s.should eq "2026-01-02"
      Date.new(2026, 12, 31).to_s.should eq "2026-12-31"
    end

    describe "using formatting strings" do
      date = Date.new(2026, 4, 17)

      it "emits a short day name" do
        date.to_s("%a").should eq "Fri"
      end

      it "emits an uppercase short day name" do
        date.to_s("%^a").should eq "FRI"
      end

      it "emits a day name" do
        date.to_s("%A").should eq "Friday"
      end

      it "emits an uppercase day name" do
        date.to_s("%^A").should eq "FRIDAY"
      end

      it "emits a short month name" do
        date.to_s("%b").should eq "Apr"
        # The duplication is a little confusing, but this is the same as what
        # `Time::Format` does.
        date.to_s("%h").should eq "Apr"
      end

      it "emits an uppercase short month name" do
        date.to_s("%^b").should eq "APR"
      end

      it "emits a month name" do
        date.to_s("%B").should eq "April"
      end

      it "emits an uppercase day of the month" do
        date.to_s("%^B").should eq "APRIL"
      end

      it "emits the century" do
        date.to_s("%C").should eq "20"
      end

      it "emits the day of the month, zero-padded" do
        Date.new(2026, 4, 7).to_s("%d").should eq "07"
      end

      it "emits the day of the month" do
        Date.new(2026, 4, 7).to_s("%-d").should eq "7"
      end

      it "emits MM/DD/YY" do
        date.to_s("%D").should eq "04/17/26"
        date.to_s("%x").should eq "04/17/26"
      end

      it "emits the day of the month, blank-padded" do
        Date.new(2026, 4, 7).to_s("%e").should eq " 7"
      end

      it "emits an ISO8601 date" do
        date.to_s("%F").should eq "2026-04-17"
      end

      it "emits the week-based calendar year modulo 100" do
        date.to_s("%g").should eq "26"
      end

      it "emits the week-based calendar year" do
        date.to_s("%G").should eq "2026"
      end

      it "emits the day of the year, zero-padded to 3 digits" do
        Date.new(2026, 1, 23).to_s("%j").should eq "023"
      end

      it "emits the month number, zero-padded" do
        date.to_s("%m").should eq "04"
      end

      it "emits the month number, blank-padded" do
        date.to_s("%_m").should eq " 4"
      end

      it "emits the month number" do
        date.to_s("%-m").should eq "4"
      end

      it "emits the numeric day of the week 1..7" do
        date.to_s("%u").should eq "5"
        (date + 2.calendar_days).to_s("%u").should eq "7"
      end

      it "emits the ISO calendar week of the week-based year" do
        date.to_s("%V").should eq "16"
      end

      it "emits the numeric day of the week 0..6" do
        date.to_s("%w").should eq "5"
        (date + 2.calendar_days).to_s("%w").should eq "0"
      end

      it "emits the year modulo 100" do
        date.to_s("%y").should eq "26"
      end

      it "emits the year, zero-padded" do
        date.to_s("%Y").should eq "2026"
        Date.new(1, 1, 1).to_s("%Y").should eq "0001"
      end

      it "emits multiple values with additional text" do
        date.to_s("Today is %A, %B %-d, %Y")
          .should eq "Today is Friday, April 17, 2026"
      end

      it "emits a newline character" do
        date.to_s("%n").should eq "\n"
      end

      it "emits a tab character" do
        date.to_s("%t").should eq "\t"
      end
    end
  end

  describe "parsing" do
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
end
