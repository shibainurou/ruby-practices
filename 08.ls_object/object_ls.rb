#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'

Struct.new('Display', :filename, :type, :permission, :hardlink, :owner, :group, :filesize, :timestamp, :blocks)
Struct.new('MaxLenght', :filename, :type, :permission, :hardlink, :owner, :group, :filesize, :timestamp)

def colmuns_information(file_list)
  list = []
  max_len = 0
  file_list.each do |v|
    list.push(Struct::Display.new(v))
    max_len = [max_len, v.length].max
  end
  [list, max_len]
end

def list_information(file_list, file_type_str, permission_str)
  file_list.map do |file_name|
    stat = File.lstat(file_name)
    display = Struct::Display.new(file_name)
    display.filename = file_name
    display.type = file_type_str[stat.ftype]
    display.permission = print_permission(stat.mode, permission_str)
    display.hardlink = stat.nlink.to_s
    display.owner = Etc.getpwuid(stat.uid).name
    display.group = Etc.getgrgid(stat.gid).name
    display.filesize = stat.size
    display.timestamp = stat.mtime.strftime('%_m %_d %H:%M')
    display.blocks = stat.blocks
    display
  end
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

def target_files(show_dotfile_flag)
  flag = 0
  flag = File::FNM_DOTMATCH if show_dotfile_flag

  Dir.glob('*', flag)
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
      print file.filename.ljust(max_len).concat("\t") unless file.nil?
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

class OptionParser
  attr_reader :show_dotfile_flag, :reverse_flag, :list_flag

  def initialize(argv)
    show_dotfile_flag, reverse_flag, list_flag = option(argv)
  end

  def option(argv)
    %w[a r l].map do |opt|
      ARGV.any? { |v| v.start_with?('-') && v.include?(opt) }
    end
  end  
end

option = OptionParser.new(ARGV)

files = target_files(option.show_dotfile_flag)
files.reverse! if option.reverse_flag

if option.list_flag
  file_list = list_information(files, file_type_str, permission_str)
  show_list(file_list, max_lenght(file_list))
else
  file_list, max_len = colmuns_information(files)
  show_columns(file_list, max_len)
end

option = OptionParser.new(ARGV)
x = xxx(option)
x.show
