# frozen_string_literal: true

class Option
  attr_reader :include_dotfiles, :reverse_order, :list_mode

  def initialize(argv)
    @include_dotfiles, @reverse_order, @list_mode = %w[a r l].map do |opt|
      argv.any? { |v| v.start_with?('-') && v.include?(opt) }
    end
  end
end
