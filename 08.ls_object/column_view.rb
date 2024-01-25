# frozen_string_literal: true

require_relative 'base_view'

class ColumnView < BaseView
  COLUMNS = 3

  def render
    max_len = @file_names.map(&:length).max
    rows = display_rows(@file_names)

    rows.times do |row_index|
      COLUMNS.times do
        break if row_index > @file_names.size

        file = @file_names[row_index]
        print file.ljust(max_len).concat("\t") unless file.nil?
        row_index += rows
      end
      print "\n"
    end
  end

  def display_rows(list)
    (list.size.to_r / COLUMNS.to_r).to_f.ceil
  end
end
