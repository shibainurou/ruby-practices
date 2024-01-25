#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './game'

def main(pins)
  game = Game.new
  game.run(pins)

  puts game.total_score
end

main(ARGV.join.split(','))
