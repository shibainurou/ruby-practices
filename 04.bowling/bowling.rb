#!/usr/bin/env ruby
# frozen_string_literal: true

class GameJudge
  def point2score(point)
    return 0 if point.nil?

    return 10 if point == 'X'

    point.to_i
  end

  def strike(point)
    point == 'X'
  end

  def spare(point1, point2)
    return false if point1.nil? || point2.nil?

    return false if point1 == 'X'

    return true if point2score(point1) + point2score(point2) == 10

    false
  end
end

LAST_FRAME = 10

judge = GameJudge.new
total_score = 0
throw_count = 0
strike_extra_point_position = []
prev_spare = false

def split_frame(throw_list)
  frame_point = Array.new(LAST_FRAME) { [] }
  frame_index = 0
  throw_list.each do |point|
    frame_point[frame_index].push(point.to_s)
    next if frame_index == LAST_FRAME - 1

    frame_index += 1 if point == 'X' || frame_point[frame_index].count == 2
  end
  frame_point
end

split_frame(ARGV.join.split(',')).each do |throw1, throw2, throw3|
  [throw1, throw2, throw3].each do |v|
    total_score += judge.point2score(v)
  end

  total_score += judge.point2score(throw1) if prev_spare
  prev_spare = judge.spare(throw1, throw2)

  strike_extra_point_position.each do |num|
    total_score += judge.point2score(throw1) if throw_count + 1 == num
    total_score += judge.point2score(throw2) if throw_count + 2 == num
  end

  [throw1, throw2, throw3].each do |v|
    throw_count += 1 unless v.nil?
  end

  if judge.strike(throw1)
    strike_extra_point_position.push(throw_count + 1)
    strike_extra_point_position.push(throw_count + 2)
  end
end

p total_score
