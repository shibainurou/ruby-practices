#!/usr/bin/env ruby
# frozen_string_literal: true

Struct.new('Display', :filename)

def target_list(file_list)
  list = []
  max_len = 0
  file_list.each do |v|
    next if dot_file(v)

    list.push(Struct::Display.new(v))
    max_len = [max_len, v.length].max
  end
  [list, max_len]
end

def dot_file(file_name)
  file_name[0] == '.'
end

def display_rows(list, columns)
  (list.size.to_r / columns.to_r).to_f.ceil
end

num_cols = 3

list, max_len = target_list(Dir.entries('.'))

rows_num = display_rows(list, num_cols)
rows_num.times do |row|
  print_index = row
  num_cols.times do
    break if print_index > list.size

    value = list[print_index]
    # p "#{row} #{col} #{display_index(row, col, rows_num)}"
    print value.filename.ljust(max_len + 1, ' ') unless value.nil?

    print_index += rows_num
  end
  print "\n"
end
