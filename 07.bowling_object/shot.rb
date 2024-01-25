# frozen_string_literal: true

class Shot
  attr_reader :score

  STRIKE_CHARACTER = 'X'

  def initialize(score)
    @score = score == STRIKE_CHARACTER ? 10 : score.to_i
  end
end
