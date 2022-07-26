#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'

num_cols = 3
show_list_flag = false

Struct.new('Display', :filename, :type, :permission, :hardlink, :owner, :group, :filesize, :timestamp, :blocks)
Struct.new('MaxLenght', :filename, :type, :permission, :hardlink, :owner, :group, :filesize, :timestamp)

file_type_str = {
  'file' => '-',
  'blockSpecial' => 'b',
  'characterSpecial' => 'c',
  'directory' => 'd',
  'link' => 'l',
  'fifo' => 'p',
  'socket' => 's',
  'unknown' => '?'
}.freeze

permission_str = {
  0 => '-',
  4 => 'r',
  2 => 'w',
  1 => 'x'
}.freeze

def target_list(file_list, file_type_str, permission_str)
  list = []
  file_list.each do |f|
    stat = File.lstat(f)
    d = Struct::Display.new(f)
    d.filename = f
    d.type = file_type_str[stat.ftype]
    d.permission = print_permission(stat.mode, permission_str)
    d.hardlink = stat.nlink.to_s
    d.owner = Etc.getpwuid(stat.uid).name
    d.group = Etc.getgrgid(stat.gid).name
    d.filesize = stat.size
    d.timestamp = stat.mtime.strftime('%_m %_d %H:%M')
    d.blocks = stat.blocks

    list.push(d)
  end
  list
end

def max_lenght(list)
  max = Struct::MaxLenght.new(0, 0, 0, 0, 0, 0, 0, 0)
  list.each do |v|
    max.filename = [max.filename, v.filename.length].max
    max.type = [max.type, v.type.length].max
    max.permission = [max.permission, v.permission.length].max
    max.hardlink = [max.hardlink, v.hardlink.length].max
    max.owner  = [max.owner, v.owner.length].max
    max.group  = [max.group, v.group.length].max
    max.filesize = [max.filesize, v.filesize.to_s.length].max
    max.timestamp = [max.timestamp, v.timestamp.length].max
  end
  max
end

def display_rows(list, columns)
  (list.size.to_r / columns.to_r).to_f.ceil
end

def print_file_info(file, max_len)
  print file.type.rjust(max_len.type, ' ')
  print "#{file.permission.rjust(max_len.permission, ' ')}  "
  print "#{file.hardlink.rjust(max_len.hardlink, ' ')} "
  print "#{file.owner.ljust(max_len.owner, ' ')}  "
  print "#{file.group.ljust(max_len.group, ' ')}  "
  print "#{file.filesize.to_s.rjust(max_len.filesize, ' ')} "
  print "#{file.timestamp.rjust(max_len.timestamp, ' ')} "
  print file.filename
  print " -> #{File.readlink(file.filename)}" if file.type == 'l'
end

def print_permission(mode, permission_str)
  permission = ''
  # 0100744 -> 774
  mode.to_s(8)[-3, 3].split('') do |v|
    2.downto(0) do |count|
      permission += permission_str[v.to_i & (1 << count)]
    end
  end
  permission
end

ARGV.each do |v|
  next unless v.start_with?('-')

  show_list_flag = true if v.include?('l')
end

num_cols = 1 if show_list_flag

file_list = target_list(Dir.glob('*').sort, file_type_str, permission_str)
max_len = max_lenght(file_list)
rows_num = display_rows(file_list, num_cols)

puts "total #{file_list.map(&:blocks).sum}" if show_list_flag

rows_num.times do |row|
  print_index = row
  num_cols.times do
    break if print_index > file_list.size

    file = file_list[print_index]
    if show_list_flag
      print_file_info(file, max_len) if show_list_flag
    else
      print file.filename.ljust(max_len.filename, ' ').concat("\t") unless file.nil?
    end
    print_index += rows_num
  end
  print "\n"
end
