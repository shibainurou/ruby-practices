# frozen_string_literal: true

require_relative 'list_view'
require_relative 'column_view'

class LsCommand
  def run(options)
    file_names = target_files(options)
    file_names.reverse! if options.reverse_order

    klass = options.list_mode ? ListView : ColumnView
    view = klass.new(file_names)
    view.render
  end

  def target_files(options)
    flag = 0
    flag = File::FNM_DOTMATCH if options.include_dotfiles

    Dir.glob('*', flag)
  end
end
