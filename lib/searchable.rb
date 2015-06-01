module Searchable
  def where(params)
    keys = []
    values = []

    params.each do |key, value|
      keys << key
      values << value
    end

    where_line = keys.map {|key| "#{key.to_s} = ?"}.join(" AND ")

    results = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
      SQL

    results.map{ |result| self.new(result) }

  end
end
