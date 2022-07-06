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

def order_files(reverse_flag)
  files = Dir.glob('*').sort
  reverse_flag ? files.reverse : files
end

num_cols = 3
reverse_flag = false

ARGV.each do |v|
  next unless v.start_with?('-')

  reverse_flag = true if v.include?('r')
end

list, max_len = target_list(order_files(reverse_flag))

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
