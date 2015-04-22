require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    all = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{table_name}
    SQL
    cols = all.first
    cols.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      setter = "#{column.to_s}="
      define_method(setter) do |arg|
        attributes[column] = arg
      end

      define_method(column) do
        attributes[column]
      end
    end
  end
  # def id=(id)
  #attributes[:id]=id
  #end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    return @table_name if @table_name
    @table_name = self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      #{table_name}.*
    FROM
      #{table_name}

    SQL
    parse_all(results)

  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL,id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        id = ?
      SQL

    return nil if result.empty?
    self.new(result.first)

    # ...
  end

  def initialize(params = {})

    @attributes ||= Hash.new
    params.each do |attr, value|
      raise "unknown attribute '#{attr}'" if !self.class.columns.include?(attr.to_sym)
      setter = "#{attr}="
      self.send(setter, value)
    end

  end

  def attributes
    @attributes
  end

  def attribute_values
    # [].tap do |values|
    #   @attributes.each_value {|value| values << value}
    # end
    [].tap do |values|
      self.class.columns.map do |attr|
        values << self.send(attr)
      end
    end
  end

  def insert
    col_names = self.class.columns.map(&:to_s)
    question_marks = (["?"] * col_names.count).join(', ')
    col_names = col_names.join(', ')
    DBConnection.execute(<<-SQL,attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
      SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_str = self.class.columns[1..-1].map{|value| "#{value} = ?"}.join(', ')
    values = attribute_values.rotate
    # byebug

    DBConnection.execute(<<-SQL,*values)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_str}
    WHERE
      id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
