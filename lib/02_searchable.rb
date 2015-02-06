require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    Relation.new(self, params)
  end
end

class SQLObject
  extend Searchable
end

class Relation
  include Enumerable

  def initialize(klass, params={})
    @klass, @cache, @params = klass, nil, params
  end

  def where(params={})
    Relation.new(@klass, @params.merge(params))
  end

  def each(&prc)
    fetch

    @cache.each(&prc)
  end

  def length
    fetch

    @cache.length
  end

  def [](i)
    fetch

    @cache[i]
  end

  private
  def fetch
    return unless @cache.nil?

    where_condition = @params.keys.map { |p| "#{p} = :#{p}" }.join(" AND ")
    
    results = DBConnection.execute(<<-SQL, @params)
    SELECT
      *
    FROM
      #{@klass.table_name}
    WHERE
      #{where_condition}
    SQL

    @cache = @klass.parse_all(results)
  end
end
