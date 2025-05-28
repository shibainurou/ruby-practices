#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'option'
require_relative 'ls_command'

options = Option.new(ARGV)
LsCommand.new.run(options)
