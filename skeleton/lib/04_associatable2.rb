require_relative '03_associatable'

# Phase IV
module Associatable
  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      through_table   = through_options.model_class.table_name
      through_pkey    = through_options.primary_key
      through_fkey    = through_options.foreign_key

      source_options = through_options.model_class.assoc_options[source_name]
      source_table   = source_options.model_class.table_name
      source_pkey    = source_options.primary_key
      source_fkey    = source_options.foreign_key

      result = DBConnection.execute(<<-SQL, send(through_options.primary_key))
      SELECT
        #{source_table}.*
      FROM
        #{source_table}
      JOIN
        #{through_table}
      ON #{through_table}.#{source_fkey} = #{source_table}.#{source_pkey}
      WHERE
        #{through_table}.#{through_pkey} = (
          SELECT
            #{through_fkey}
          FROM
            #{self.class.table_name}
          WHERE
            #{source_pkey} = ?
        )
      SQL

      source_options.model_class.parse_all(result).first
    end
  end
end
