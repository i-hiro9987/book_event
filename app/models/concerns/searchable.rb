module Searchable
  extend ActiveSupport::Concern

  included do

  end

  class_methods do 
    def search_by_keyword(keyword)
      return all if keyword.blank?

      columns = searchable_columns.map{ |col| "#{table_name}.#{col} LIKE :keyword" }.join(" OR ")
      where(columns, keyword: "%#{keyword}%")
    end

    def searchable_columns
      raise NotImplementedError, "#{self.class.name} must implement searchable_columns"
    end
  end
end