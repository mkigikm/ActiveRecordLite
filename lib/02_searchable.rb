require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # results = DBConnection.execute(<<-SQL, params)
    # SELECT
    #   *
    # FROM
    #   #{table_name}
    # WHERE
    #   #{ params.keys.map { |p| "#{p} = :#{p}" }.join(" AND ") }
    # SQL
    #
    # parse_all(results)
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
    @params.merge!(params)
    @cache = nil
  end

  def each
    fetch

    @cache.each do |el|
      yield(el)
    end
  end

  def length
    fetch

    @cache.length
  end

  def first
    fetch

    @cache.first
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
