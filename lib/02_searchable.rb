require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    results = DBConnection.execute(<<-SQL, params)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{ params.keys.map { |p| "#{p} = :#{p}" }.join(" AND ") }
    SQL

    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
