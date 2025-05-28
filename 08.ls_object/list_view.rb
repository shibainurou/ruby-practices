# frozen_string_literal: true

require 'etc'
require_relative 'base_view'

class ListView < BaseView
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
    puts "total #{display_file_infos.map { |v| v[:blocks] }.sum}"
    display_file_infos.each do |file|
      print file[:type].rjust(row_max_len[:type])
      print "#{file[:permission].rjust(row_max_len[:permission])}  "
      print "#{file[:hard_link].rjust(row_max_len[:hard_link])} "
      print "#{file[:owner].ljust(row_max_len[:owner])}  "
      print "#{file[:group].ljust(row_max_len[:group])}  "
      print "#{file[:file_size].to_s.rjust(row_max_len[:file_size])} "
      print "#{file[:timestamp].rjust(row_max_len[:timestamp])} "
      print "#{file[:file_name]} "
      print " -> #{File.readlink(file[:file_name])}" if file[:file_name] == 'l'
      print "\n"
    end
  end

  def display_file_info
    @file_names.map do |file_name|
      stat = File.lstat(file_name)
      display = {
        file_name: file_name,
        type: FILE_TYPE_STR[stat.ftype],
        permission: print_permission(stat.mode, PERMISSION_STR),
        hard_link: stat.nlink.to_s,
        owner: Etc.getpwuid(stat.uid).name,
        group: Etc.getgrgid(stat.gid).name,
        file_size: stat.size,
        timestamp: stat.mtime.strftime('%_m %_d %H:%M'),
        blocks: stat.blocks
      }
      display
    end
  end

  def row_max_lenght(display_file_infos)
    max_len = Hash.new(0)
    display_file_infos.each do |item|
      item.each do |key, value|
        max_len[key] = [max_len[key], value.to_s.length].max
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
