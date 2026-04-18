require "benchmark"

require "../src/date"

buffer = IO::Memory.new
date = Time.utc.to_date

Benchmark.ips do |x|
  x.report "%F" { date.to_s buffer.rewind, "%F" }
  x.report "long string" { date.to_s buffer.rewind, "Today is %A, %B %-d, %Y" }
end
