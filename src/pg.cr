require "pg"

struct Date
  def self.new(rs : DB::ResultSet)
    # The `pg` gem parses Postgres `date` columns as Crystal `Time` values
    new rs.read(Time)
  end
end

class PG::ResultSet
  def read(date : Date.class)
    Date.new self
  end

  def read(date : Date?.class)
    if time = read(Time?)
      Date.new time
    end
  end
end
