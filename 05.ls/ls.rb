#!/usr/bin/env ruby
# frozen_string_literal: true

Struct.new('Display', :filename)

def files_information(file_list)
  list = []
  max_len = 0
  file_list.each do |v|
    list.push(Struct::Display.new(v))
    max_len = [max_len, v.length].max
  end
  [list, max_len]
end

def display_rows(list, columns)
  (list.size.to_r / columns.to_r).to_f.ceil
end

def target_files(show_dotfile_flag)
  flag = 0
  flag = File::FNM_DOTMATCH if show_dotfile_flag

  Dir.glob('*', flag)
end

def option
  show_dotfile_flag = false
  reverse_flag = false
  ARGV.each do |v|
    next unless v.start_with?('-')

    show_dotfile_flag = true if v.include?('a')
    reverse_flag = true if v.include?('r')
  end
  [show_dotfile_flag, reverse_flag]
end

num_cols = 3
show_dotfile_flag, reverse_flag = option

files = target_files(show_dotfile_flag)
files.reverse if reverse_flag

list, max_len = files_information(files)

rows_num = display_rows(list, num_cols)
rows_num.times do |row|
  print_index = row
  num_cols.times do
    break if print_index > list.size

    value = list[print_index]
    print value.filename.ljust(max_len, ' ').concat("\t") unless value.nil?

    print_index += rows_num
  end
  print "\n"
end
