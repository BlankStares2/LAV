# Basic test requires
require 'active_record'
require 'minitest/autorun'
require 'minitest/pride'
require './lesson'
require './reading'
require 'byebug'

# Include both the migration and the app itself
require './migration'
require './application'

ActiveRecord::Migration.verbose = false
# Overwrite the development database connection with a test connection.
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

# Gotta run migrations before we can run tests.  Down will fail the first time,
# so we wrap it in a begin/rescue.
begin ApplicationMigration.migrate(:down); rescue; end
ApplicationMigration.migrate(:up)


# Finally!  Let's test the thing.
class ApplicationTest < Minitest::Test

  def test_truth
    assert true
  end

  def test_lessons_have_readings
    lesson = Lesson.new(name: "Math")
    reading = Reading.new(name: "Addition")

    lesson.add_reading(reading)
    assert "Addition", lesson.readings.first.name
  end

end
