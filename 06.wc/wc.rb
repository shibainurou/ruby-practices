#!/usr/bin/env ruby
# frozen_string_literal: true

require 'etc'

def splite_argumnet
  options_str = ''
  files = []
  option_flag = false
  ARGV.each do |opt|
    if opt.start_with?('-') && option_flag == false
      options_str += opt.delete('-')
    else
      files.push(opt)
      option_flag = true
    end
  end
  options_str = 'lwc' if options_str.empty?
  [options_str, files]
end

Struct.new('WcData', :filename, :line_count, :word_count, :byte_count)
def count_contents(str, wcdata)
  result = wcdata.dup
  str.each_line do |line|
    result.line_count += 1
    result.word_count += line.split.size
    result.byte_count += line.bytesize
  end
  result
end

Struct.new('MaxLenght', :filename, :line, :word, :byte)
def max_length(wcdata_list)
  max = Struct::MaxLenght.new(0, 0, 0, 0)
  wcdata_list.each do |v|
    max.filename = [max.filename, v.filename.length].max
    max.line = [max.line, v.line_count.to_s.length].max
    max.word = [max.word, v.word_count.to_s.length].max
    max.byte = [max.byte, v.byte_count.to_s.length].max
  end
  max
end

options_str, files = splite_argumnet

disp_lines = []
if files.empty?
  disp_lines.push(count_contents($stdin, Struct::WcData.new('', 0, 0, 0)))
else
  files.each do |file_name|
    wcdata = Struct::WcData.new(file_name, 0, 0, 0)
    File.foreach(file_name) do |line|
      wcdata = count_contents(line, wcdata)
    end
    disp_lines.push(wcdata)
  end
end

max_len = max_length(disp_lines)

disp_lines.each do |v|
  print v.line_count.to_s.rjust(max_len.line).prepend('     ') if options_str.include?('l')
  print v.word_count.to_s.rjust(max_len.word).prepend('     ') if options_str.include?('w')
  print v.byte_count.to_s.rjust(max_len.byte).prepend('     ') if options_str.include?('c')
  print v.filename.ljust(max_len.filename).prepend(' ') unless v.nil?
  puts
end

if disp_lines.all? { |v| !v.filename.nil? } && disp_lines.count > 1
  print disp_lines.sum(&:line_count).to_s.rjust(max_len.line).prepend('     ') if options_str.include?('l')
  print disp_lines.sum(&:word_count).to_s.rjust(max_len.word).prepend('     ') if options_str.include?('w')
  print disp_lines.sum(&:byte_count).to_s.rjust(max_len.byte).prepend('     ') if options_str.include?('c')
  print 'total'.ljust(max_len.filename).prepend(' ')
  puts
end
