# date

This shard provides a `Date` type without a timestamp. This is useful when you need to measure things in calendar days where a time component complicates things. For example, if a subscription expires on a certain date, you don't necessarily need to mark a time on that day that the subscription expires and, in fact, using a timestamp means you have to decide whether to use the time of day or truncate to the day boundary. Then you have to apply that logic consistently throughout your app. If instead, you use a date representation that has no time of day, this just works for you.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     date:
       github: jgaskins/date
   ```

2. Run `shards install`

## Usage

```crystal
require "date"

Date.new(2026, 1, 23)    # => Date(@year=2026, @month=1, @day=23)
Date.parse("2026-01-23") # => Date(@year=2026, @month=1, @day=23)
```

### Using with Postgres `date` columns

By default, the `pg` shard parses `date` values coming back from Postgres as Crystal `Time` instances, but you can also read them as `Date` values.

```crystal
require "date/pg"

db = DB.open("postgres:///")

db.exec <<-SQL
  CREATE TABLE subscriptions(
    id uuid PRIMARY KEY DEFAULT uuidv7(), -- requires Postgres 18
    expires_on date NOT NULL
  )
SQL

at_exit { db.exec "DROP TABLE IF EXISTS subscriptions" }

# Insert one expired and one active subscription
db.exec <<-SQL
  INSERT INTO subscriptions (expires_on)
  VALUES
    ('2020-01-23'),
    ('2090-02-26')
SQL

# Only returns the expired subscription
pp expired = db.query_all <<-SQL, as: {UUID, Date}
  SELECT id, expires_on
  FROM subscriptions
  WHERE expires_on < now()
SQL
# [{UUID(019c9d38-8462-7660-8506-65f490826fe9),
#   Date(@day=23, @month=1, @year=2020)}]
```

You can also use it with `DB::Serializable`.

```crystal
struct Subscription
  include DB::Serializable

  getter id : UUID
  getter expires_on : Date
end

pp expired = db.query_all <<-SQL, as: Subscription
  SELECT id, expires_on
  FROM subscriptions
  WHERE expires_on < now()
SQL
# [Subscription(
#   @expires_on=Date(@day=23, @month=1, @year=2020),
#   @id=UUID(019c9d3a-39cb-7640-8593-266f9f4747cd))]
```

## Contributing

1. Fork it (<https://github.com/jgaskins/date/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jamie Gaskins](https://github.com/jgaskins) - creator and maintainer
