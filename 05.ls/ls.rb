#!/usr/bin/env ruby
# frozen_string_literal: true

Struct.new('Display', :filename)

def target_list(file_list)
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

num_cols = 3
show_dotfile_flag = false

ARGV.each do |v|
  next unless v.start_with?('-')

  show_dotfile_flag = true if v.include?('a')
end

list, max_len = target_list(target_files(show_dotfile_flag))

rows_num = display_rows(list, num_cols)
rows_num.times do |row|
  print_index = row
  num_cols.times do
    break if print_index > list.size

    value = list[print_index]
    print value.filename.ljust(max_len + 1, ' ') unless value.nil?

    print_index += rows_num
  end
  print "\n"
end
