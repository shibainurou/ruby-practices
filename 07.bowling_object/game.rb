# frozen_string_literal: true

require_relative './frame'

class Game
  attr_accessor :frame

  MAX_FRAMES_PER_GAME = 10
  MAX_SHOTS_PER_FRAME = 3

  def initialize
    @frames = []
    @bonus_frames = []
    MAX_FRAMES_PER_GAME.times do
      @frames << Frame.new
    end
  end

  def run(pins)
    @frames.each_with_index do |frame, frame_index|
      MAX_SHOTS_PER_FRAME.times do
        play_frame(pins.shift, frame)

        @bonus_frames << frame if !last_frame?(frame_index) && (frame.strike? || frame.spare?)

        break if !last_frame?(frame_index) && (frame.strike? || frame.shots.size >= 2)
      end
    end
  end

  def play_frame(score, frame)
    frame.take_shot(score)

    return if @bonus_frames.empty?

    frame.calculate_bonus(@bonus_frames)
    @bonus_frames.reject!(&:bonus_complate?)
  end

  # Gameクラスが全体の流れを制御しているので
  # 最終フレーム or NOTはGameクラスで判断する
  def last_frame?(frame_index)
    frame_index == MAX_FRAMES_PER_GAME - 1
  end

  def total_score
    @frames.inject(0) { |sum, frame| sum + frame.score }
  end
end
