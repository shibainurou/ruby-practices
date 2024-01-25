# frozen_string_literal: true

require 'etc'
require_relative 'base_view'

class ListView < BaseView
  Struct.new('Display', :filename, :type, :permission, :hardlink, :owner, :group, :filesize, :timestamp, :blocks)
  Struct.new('MaxLenght', :filename, :type, :permission, :hardlink, :owner, :group, :filesize, :timestamp)

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

    puts "total #{display_file_infos.map(&:blocks).sum}"
    display_file_infos.each do |file|
      print file.type.rjust(row_max_len.type)
      print "#{file.permission.rjust(row_max_len.permission)}  "
      print "#{file.hardlink.rjust(row_max_len.hardlink)} "
      print "#{file.owner.ljust(row_max_len.owner)}  "
      print "#{file.group.ljust(row_max_len.group)}  "
      print "#{file.filesize.to_s.rjust(row_max_len.filesize)} "
      print "#{file.timestamp.rjust(row_max_len.timestamp)} "
      print file.filename
      print " -> #{File.readlink(file.filename)}" if file.type == 'l'
      print "\n"
    end
  end

  def display_file_info
    @file_names.map do |f|
      d = Struct::Display.new(f)
      stat = File.lstat(f)
      d.filename = f
      d.type = FILE_TYPE_STR[stat.ftype]
      d.permission = print_permission(stat.mode, PERMISSION_STR)
      d.hardlink = stat.nlink.to_s
      d.owner = Etc.getpwuid(stat.uid).name
      d.group = Etc.getgrgid(stat.gid).name
      d.filesize = stat.size
      d.timestamp = stat.mtime.strftime('%_m %_d %H:%M')
      d.blocks = stat.blocks
      d
    end
  end

  def row_max_lenght(display_file_infos)
    max_len = Struct::MaxLenght.new(0, 0, 0, 0, 0, 0, 0, 0)
    display_file_infos.each do |v|
      max_len.filename = [max_len.filename, v.filename.length].max
      max_len.type = [max_len.type, v.type.length].max
      max_len.permission = [max_len.permission, v.permission.length].max
      max_len.hardlink = [max_len.hardlink, v.hardlink.length].max
      max_len.owner = [max_len.owner, v.owner.length].max
      max_len.group = [max_len.group, v.group.length].max
      max_len.filesize = [max_len.filesize, v.filesize.to_s.length].max
      max_len.timestamp = [max_len.timestamp, v.timestamp.length].max
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
