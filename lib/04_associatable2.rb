require_relative '03_associatable'

# Phase IV
module Associatable
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      thru_options   = self.class.assoc_options[through_name]
      thru_table     = thru_options.model_class.table_name
      thru_pkey      = thru_options.primary_key
      thru_fkey      = thru_options.foreign_key

      source_options = thru_options.model_class.assoc_options[source_name]
      source_table   = source_options.model_class.table_name
      source_pkey    = source_options.primary_key
      source_fkey    = source_options.foreign_key

      result = DBConnection.execute(<<-SQL, send(thru_options.foreign_key))
      SELECT
        #{source_table}.*
      FROM
        #{source_table}
      JOIN
        #{thru_table}
      ON #{thru_table}.#{source_fkey} = #{source_table}.#{source_pkey}
      WHERE
        #{thru_table}.#{thru_pkey} = ?
      SQL

      source_options.model_class.parse_all(result).first
    end
  end
end
