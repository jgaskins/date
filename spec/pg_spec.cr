require "./spec_helper"
require "../src/pg"

db = DB.open("postgres:///")

describe Date do
  it "parses Postgres `date` types" do
    date = db.query_one("select '2026-02-26'::date", as: Date)
    date.should eq Date.new(2026, 2, 26)
  end

  it "parses inside a DB::Serializable" do
    user = db.query_one(<<-SQL, as: User)
      SELECT
        gen_random_uuid() id,
        'Jamie' name,
        '2026-02-26'::date created_on,
        NULL sms_verified_on,
        '2026-02-27'::date email_verified_on
    SQL

    user.created_on.should eq Date.new(2026, 2, 26)
    user.sms_verified_on.should be_nil
    user.email_verified_on.should eq Date.new(2026, 2, 27)
  end
end

struct User
  include DB::Serializable

  getter id : UUID
  getter name : String
  getter created_on : Date
  getter sms_verified_on : Date?
  getter email_verified_on : Date?
end
