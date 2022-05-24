#!/usr/bin/env ruby
require 'optparse'
require 'date'

# param
begin
  params = ARGV.getopts("y:m:")
rescue
  params = {}
end

if params["y"].nil?
  params["y"] = Date.today.year
end
if params["m"].nil? || !(1 <= params["m"].to_i && params["m"].to_i <= 12)
  params["m"] = Date.today.month
end

params["y"] = params["y"].to_i
params["m"] = params["m"].to_i


CHAR_SIZE = 2
MARGIN = 1
SCR_WIDTH = (7 * CHAR_SIZE) + (MARGIN * 6)

title = params["m"].to_s + "月 " + params["y"].to_s
header = ["日", "月", "火", "水", "木", "金", "土"]

# title
print " " * ((SCR_WIDTH - title.size) / 2)
puts title

# header
puts header.join(" " * MARGIN)

# calender
firstDate = Date.new(params["y"], params["m"], 1)
lastDate = Date.new(params["y"], params["m"], -1)
print " " * (firstDate.wday * (CHAR_SIZE + MARGIN))

(firstDate..lastDate).each do |date|
  print date.day.to_s.rjust(CHAR_SIZE)
  if date.saturday?
    puts ""
  else
    print " " * MARGIN
  end
end

if !lastDate.saturday?
  puts ""
end
