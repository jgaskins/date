require "duration"

struct Date
  include Comparable(self)
  include Steppable

  VERSION = "0.1.0"

  alias DayOfWeek = Time::DayOfWeek

  DAY_NAMES_SHORT   = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
  DAY_NAMES_LONG    = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
  MONTH_NAMES_SHORT = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}
  MONTH_NAMES_LONG  = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}

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

  def at_beginning_of_week(start_of_week : DayOfWeek) : self
    self.class.new to_time.at_beginning_of_week(start_of_week)
  end

  def at_end_of_week(start_of_week : DayOfWeek) : self
    # self.class.new to_time.at_end_of_week(start_of_week)
    at_beginning_of_week(start_of_week) + 6.calendar_days
  end

  def at_beginning_of_month : self
    self.class.new to_time.at_beginning_of_month
  end

  def at_end_of_month : self
    self.class.new to_time.at_end_of_month
  end

  def at_beginning_of_year : self
    self.class.new to_time.at_beginning_of_year
  end

  def at_end_of_year : self
    self.class.new to_time.at_end_of_year
  end

  def to_s(io : IO) : Nil
    io << year << '-'
    io << '0' if month < 10
    io << month << '-'
    io << '0' if day < 10
    io << day
  end

  def to_s(format : String) : String
    String.build { |str| to_s str, format }
  end

  def to_s(io : IO, format : String) : Nil
    Formatter.new(self, format).to_s(io)
  end

  private def validate!
    Time.local(year, month, day)
  rescue ex : ArgumentError
    raise ArgumentError.new("Invalid date: %4d-%02d-%02d" % {year, month, day})
  end

  struct Formatter
    def initialize(@date : Date, @format : String)
    end

    def to_s(io : IO) : Nil
      i = 0
      while i < @format.bytesize
        if @format.byte_at(i) == 0x25_u8 # '%'
          i &+= 1
          break if i >= @format.bytesize

          upcase = false
          no_pad = false
          blank_pad = false

          while i < @format.bytesize
            case @format.byte_at(i)
            when 0x5E_u8 then upcase = true; i &+= 1    # '^'
            when 0x2D_u8 then no_pad = true; i &+= 1    # '-'
            when 0x5F_u8 then blank_pad = true; i &+= 1 # '_'
            else break
            end
          end
          break if i >= @format.bytesize

          case @format.byte_at(i).unsafe_chr
          when 'a'
            write_string(io, DAY_NAMES_SHORT[weekday], upcase)
          when 'A'
            write_string(io, DAY_NAMES_LONG[weekday], upcase)
          when 'b', 'h'
            write_string(io, MONTH_NAMES_SHORT[@date.month &- 1], upcase)
          when 'B'
            write_string(io, MONTH_NAMES_LONG[@date.month &- 1], upcase)
          when 'C'
            io << (@date.year // 100)
          when 'd'
            pad = no_pad ? '\0' : (blank_pad ? ' ' : '0')
            write_number(io, @date.day.to_i32, 2, pad)
          when 'D', 'x'
            write_number(io, @date.month.to_i32, 2, '0')
            io << '/'
            write_number(io, @date.day.to_i32, 2, '0')
            io << '/'
            write_number(io, (@date.year % 100).to_i32, 2, '0')
          when 'e'
            pad = no_pad ? '\0' : ' '
            write_number(io, @date.day.to_i32, 2, pad)
          when 'F'
            write_number(io, @date.year.to_i32, 4, '0')
            io << '-'
            write_number(io, @date.month.to_i32, 2, '0')
            io << '-'
            write_number(io, @date.day.to_i32, 2, '0')
          when 'g'
            _, iso_yr = iso_week_and_year
            write_number(io, iso_yr % 100, 2, '0')
          when 'G'
            _, iso_yr = iso_week_and_year
            write_number(io, iso_yr, 4, '0')
          when 'j'
            write_number(io, day_of_year, 3, '0')
          when 'm'
            pad = no_pad ? '\0' : (blank_pad ? ' ' : '0')
            write_number(io, @date.month.to_i32, 2, pad)
          when 'n'
            io << '\n'
          when 't'
            io << '\t'
          when 'u'
            dow = weekday
            io << (dow == 0 ? 7 : dow)
          when 'V'
            week, _ = iso_week_and_year
            write_number(io, week, 2, '0')
          when 'w'
            io << weekday
          when 'y'
            write_number(io, (@date.year % 100).to_i32, 2, '0')
          when 'Y'
            write_number(io, @date.year.to_i32, 4, '0')
          when '%'
            io << '%'
          end
        else
          io << @format.byte_at(i).unsafe_chr
        end
        i &+= 1
      end
    end

    # Tomohiko Sakamoto's algorithm: 0=Sunday, 1=Monday, ..., 6=Saturday
    private def weekday : Int32
      y = @date.year.to_i32
      m = @date.month.to_i32
      d = @date.day.to_i32
      t = StaticArray[0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
      y &-= 1 if m < 3
      (y &+ y // 4 &- y // 100 &+ y // 400 &+ t[m &- 1] &+ d) % 7
    end

    private def day_of_year : Int32
      cumulative = StaticArray[0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
      doy = cumulative[@date.month &- 1] &+ @date.day.to_i32
      doy &+= 1 if @date.month > 2 && leap_year?(@date.year)
      doy
    end

    private def leap_year?(y : Int) : Bool
      (y % 4 == 0 && y % 100 != 0) || y % 400 == 0
    end

    private def iso_week_and_year : {Int32, Int32}
      dow = weekday
      iso_dow = dow == 0 ? 7 : dow

      doy = day_of_year
      yr = @date.year.to_i32

      # Find the ordinal day of the Thursday in the same ISO week
      thursday_doy = doy &+ (4 &- iso_dow)
      year_len = leap_year?(yr) ? 366 : 365

      if thursday_doy < 1
        yr &-= 1
        prev_year_len = leap_year?(yr) ? 366 : 365
        week = (thursday_doy &+ prev_year_len &- 1) // 7 &+ 1
        {week, yr}
      elsif thursday_doy > year_len
        {1, yr &+ 1}
      else
        week = (thursday_doy &- 1) // 7 &+ 1
        {week, yr}
      end
    end

    private def write_number(io : IO, value : Int, width : Int, pad : Char) : Nil
      if pad != '\0'
        digits = 0
        v = value
        if v <= 0
          digits = 1
        else
          while v > 0
            digits &+= 1
            v //= 10
          end
        end
        (width &- digits).times { io << pad }
      end
      io << value
    end

    private def write_string(io : IO, str : String, upcase : Bool) : Nil
      if upcase
        str.upcase io
      else
        io << str
      end
    end
  end
end

struct Time
  def to_date : Date
    Date.new self
  end
end
