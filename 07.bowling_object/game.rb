# frozen_string_literal: true

require_relative './frame'

class Game
  attr_accessor :frame

  MAX_FRAMES_PER_GAME = 10
  MAX_SHOTS_PER_FRAME = 3

  def initialize
    @frames = Array.new(MAX_FRAMES_PER_GAME) { Frame.new }
  end

  def run(pins)
    bonus_frames = []

    @frames.each_with_index do |frame, frame_index|
      MAX_SHOTS_PER_FRAME.times do
        frame.take_shot(pins.shift)

        if bonus_frames.any?
          frame.calculate_bonus(bonus_frames)
          bonus_frames.reject!(&:bonus_complate?)
        end

        next if last_frame?(frame_index)

        bonus_frames << frame if frame.requre_bonus?

        break if frame.complete?
      end
    end
  end

  # Gameクラスが全体の流れを制御しているので
  # 最終フレーム or NOTはGameクラスで判断する
  def last_frame?(frame_index)
    frame_index == MAX_FRAMES_PER_GAME - 1
  end

  def total_score
    @frames.sum(&:score)
  end
end
