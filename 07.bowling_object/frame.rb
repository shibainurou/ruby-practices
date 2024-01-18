# frozen_string_literal: true

require_relative './shot'

class Frame
  attr_reader :score
  attr_accessor :shots

  def initialize
    @shots = []
    @score = 0
    @bonus_count = 0
  end

  def take_shot(score)
    @shots << Shot.new(score)
    @score += @shots.last.score

    @bonus_count = 2 if strike?
    @bonus_count = 1 if spare?
  end

  def strike?
    @shots.first.score == 10
  end

  def spare?
    @shots.size == 2 && @score == 10
  end

  def bonus_complate?
    @bonus_count.zero?
  end

  def calculate_bonus(bonus_frames)
    bonus_frames.each do |bonus_frame|
      bonus_frame.add_bounus_score(@shots[-1].score)
    end
  end

  def add_bounus_score(score)
    @score += score
    @bonus_count -= 1
  end
end
