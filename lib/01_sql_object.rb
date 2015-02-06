require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    DBConnection.execute2(<<-SQL).first.map { |col| col.to_sym }
    SELECT
      *
    FROM
      #{table_name}
    LIMIT
      1
    SQL
  end

  def self.finalize!
    columns.each do |col|
      define_method(col) { attributes[col] }
      define_method("#{col}=") { |value| attributes[col] = value }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || name.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |result|
      new(result)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      id = ?
    SQL

    parse_all(result).first
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end

      send("#{attr_name.to_s}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attr_name| send(attr_name) }
  end

  def insert
    attr_names = self.class.columns.join(",")
    value_placeholder = (["?"] * self.class.columns.count).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{attr_names})
    VALUES
      (#{value_placeholder})
    SQL

    send(:id=, DBConnection.last_insert_row_id)

    self
  end

  def update
    attr_names = self.class.columns.map do |col|
      "#{col} = :#{col}"
    end.join(", ")

    DBConnection.execute(<<-SQL, attributes)
    UPDATE
      #{self.class.table_name}
    SET
      #{attr_names}
    WHERE
      id = :id
    SQL

    self
  end

  def save
    id.nil? ? insert : update
  end
end
