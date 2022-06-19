#!/usr/bin/env ruby
# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'ls'

class Testls < Minitest::Test
  def test_target_list
    assert_equal 1, display_rows(target_list([:hoge])[0], 3)
    assert_equal 1, display_rows(target_list(%i[hoge piyo foo])[0], 3)
    assert_equal 2, display_rows(target_list(%i[hoge piyo foo bar])[0], 3)
    assert_equal 1, display_rows(target_list(%i[hoge piyo foo bar])[0], 4)
    assert_equal 2, display_rows(target_list(%i[hoge piyo foo bar bar])[0], 3)
  end
end
