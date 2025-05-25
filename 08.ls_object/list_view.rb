# frozen_string_literal: true

require 'etc'
require_relative 'base_view'

class ListView < BaseView
  LEN_INDEX_MAX = 8

  module DisplayIndex
    FILE_NAME = 0
    TYPE = 1
    PERMISSION = 2
    HARD_LINK = 3
    OWNER = 4
    GROUP = 5
    FILE_SIZE = 6
    TIMESTAMP = 7
    BLOCKS = 8
  end

  FILE_TYPE_STR = {
    'file' => '-',
    'blockSpecial' => 'b',
    'characterSpecial' => 'c',
    'directory' => 'd',
    'link' => 'l',
    'fifo' => 'p',
    'socket' => 's',
    'unknown' => '?'
  }.freeze

  PERMISSION_STR = {
    0 => '-',
    4 => 'r',
    2 => 'w',
    1 => 'x'
  }.freeze

  def render
    display_file_infos = display_file_info
    row_max_len = row_max_lenght(display_file_infos)
    puts "total #{display_file_infos.map { |v| v[DisplayIndex::BLOCKS] }.sum}"
    display_file_infos.each do |file|
      print file[DisplayIndex::TYPE].rjust(row_max_len[DisplayIndex::TYPE])
      print "#{file[DisplayIndex::PERMISSION].rjust(row_max_len[DisplayIndex::TYPE])}  "
      print "#{file[DisplayIndex::HARD_LINK].rjust(row_max_len[DisplayIndex::HARD_LINK])} "
      print "#{file[DisplayIndex::OWNER].ljust(row_max_len[DisplayIndex::OWNER])}  "
      print "#{file[DisplayIndex::GROUP].ljust(row_max_len[DisplayIndex::GROUP])}  "
      print "#{file[DisplayIndex::FILE_SIZE].to_s.rjust(row_max_len[DisplayIndex::FILE_SIZE])} "
      print "#{file[DisplayIndex::TIMESTAMP].rjust(row_max_len[DisplayIndex::TIMESTAMP])} "
      print "#{file[DisplayIndex::FILE_NAME]} "
      print " -> #{File.readlink(file[DisplayIndex::FILE_NAME])}" if file[DisplayIndex::TYPE] == 'l'
      print "\n"
    end
  end

  def display_file_info
    @file_names.map do |file_name|
      display = []
      stat = File.lstat(file_name)
      display[DisplayIndex::FILE_NAME] = file_name
      display[DisplayIndex::TYPE] = FILE_TYPE_STR[stat.ftype]
      display[DisplayIndex::PERMISSION] = print_permission(stat.mode, PERMISSION_STR)
      display[DisplayIndex::HARD_LINK] = stat.nlink.to_s
      display[DisplayIndex::OWNER] = Etc.getpwuid(stat.uid).name
      display[DisplayIndex::GROUP] = Etc.getgrgid(stat.gid).name
      display[DisplayIndex::FILE_SIZE] = stat.size
      display[DisplayIndex::TIMESTAMP] = stat.mtime.strftime('%_m %_d %H:%M')
      display[DisplayIndex::BLOCKS] = stat.blocks
      display
    end
  end

  def row_max_lenght(display_file_infos)
    max_len = []
    display_file_infos.each do |v|
      LEN_INDEX_MAX.times do |index|
        max_len[index] = [max_len[index].to_i, v[index].to_s.length].max
      end
    end
    max_len
  end

  def print_permission(mode, permission_str)
    # 0100744 -> 774
    mode.to_s(8)[-3, 3].split('').map do |v|
      2.downto(0).map { |count| permission_str[v.to_i & (1 << count)] }.join
    end.join
  end
end
