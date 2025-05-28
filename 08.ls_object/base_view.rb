# frozen_string_literal: true

class BaseView
  def initialize(file_names)
    @file_names = file_names
    @file_infos = file_names.map do |file_name|
      File.lstat(file_name)
    end
  end

  def render
    raise NotImplementedError, 'renderはサブクラスで定義する'
  end
end
