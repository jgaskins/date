require "../src/pg"

db = DB.open("postgres:///")

db.exec <<-SQL
  CREATE TABLE subscriptions(
    id uuid PRIMARY KEY DEFAULT uuidv7(), -- requires Postgres 18
    expires_on date NOT NULL
  )
SQL

at_exit { db.exec "DROP TABLE IF EXISTS subscriptions" }

db.exec <<-SQL
  INSERT INTO subscriptions (expires_on)
  VALUES
    ('2020-01-23'),
    ('2090-02-26')
SQL

pp expired = db.query_all <<-SQL, as: Subscription
  SELECT id, expires_on
  FROM subscriptions
  WHERE expires_on < now()
SQL

struct Subscription
  include DB::Serializable

  getter id : UUID
  getter expires_on : Date
end
