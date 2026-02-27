require "duration"

# TODO: Write documentation for `Date`
struct Date
  include Comparable(self)
  include Steppable

  VERSION = "0.1.0"

  alias DayOfWeek = Time::DayOfWeek

  getter year : Int16
  getter month : Int8
  getter day : Int8

  def self.parse(string : String, pattern : String = "%F")
    new Time.parse(string, pattern, Time::Location.local)
  rescue ex : Time::Format::Error
    raise ArgumentError.new("Invalid date: #{string.inspect} (parsed with format: #{pattern.inspect}")
  end

  def self.new(time : Time)
    new time.year.to_i16, time.month.to_i8, time.day.to_i8
  end

  def self.new(year : Int, month : Int, day : Int)
    new year.to_i16, month.to_i8, day.to_i8
  end

  def initialize(@year : Int16, @month : Int8, @day : Int8)
    validate!
  end

  def +(duration : Duration)
    self.class.new(to_time + duration)
  end

  def +(span : Time::Span)
    self.class.new(to_time + span)
  end

  def +(span : Time::MonthSpan)
    self.class.new(to_time + span)
  end

  def -(other : Duration | Time::Span)
    self + -other
  end

  def -(other : Time::MonthSpan)
    self + (-other.value).months
  end

  def day_of_week : Time::DayOfWeek
    to_time.day_of_week
  end

  def to_time(location : Time::Location = Time::Location.local)
    Time.local(year, month, day, location: location)
  end

  def <=>(other : self)
    {year, month, day} <=> {other.year, other.month, other.day}
  end

  def succ
    self + 1.calendar_day
  end

  private def validate!
    Time.local(year, month, day)
  rescue ex : ArgumentError
    raise ArgumentError.new("Invalid date: %4d-%02d-%02d" % {year, month, day})
  end
end

struct Time
  def to_date : Date
    Date.new self
  end
end
