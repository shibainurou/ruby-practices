#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'

Struct.new('Display', :filename, :type, :permission, :hardlink, :owner, :group, :filesize, :timestamp, :blocks)
Struct.new('MaxLenght', :filename, :type, :permission, :hardlink, :owner, :group, :filesize, :timestamp)

def target_list(file_list, file_type_str, permission_str)
  list = []
  file_list.map do |f|
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
  print file.type.rjust(max_len.type)
  print "#{file.permission.rjust(max_len.permission)}  "
  print "#{file.hardlink.rjust(max_len.hardlink)} "
  print "#{file.owner.ljust(max_len.owner)}  "
  print "#{file.group.ljust(max_len.group)}  "
  print "#{file.filesize.to_s.rjust(max_len.filesize)} "
  print "#{file.timestamp.rjust(max_len.timestamp)} "
  print file.filename
  print " -> #{File.readlink(file.filename)}" if file.type == 'l'
end

def print_permission(mode, permission_str)
  # 0100744 -> 774
  mode.to_s(8)[-3, 3].split('').map do |v|
    2.downto(0).map { |count| permission_str[v.to_i & (1 << count)] }.join
  end.join
end

def option_l(argv)
  argv.any? do |v|
    v.start_with?('-') && v.include?('l')
  end
end

def show_list(file_list, max_len)
  puts "total #{file_list.map(&:blocks).sum}"

  file_list.each do |v|
    print_file_info(v, max_len)
    print "\n"
  end
end

def show_columns(file_list, max_len)
  column_count = 3
  rows_num = display_rows(file_list, column_count)

  rows_num.times do |row|
    print_index = row
    column_count.times do
      break if print_index > file_list.size

      file = file_list[print_index]
      print file.filename.ljust(max_len.filename).concat("\t") unless file.nil?
      print_index += rows_num
    end
    print "\n"
  end
end

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

file_list = target_list(Dir.glob('*').sort, file_type_str, permission_str)
max_len = max_lenght(file_list)

if option_l(ARGV)
  show_list(file_list, max_len)
else
  show_columns(file_list, max_len)
end
