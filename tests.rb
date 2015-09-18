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

  def test_destroy_lessons
    lesson = Lesson.new(name: "Math")
    reading = Reading.new(name: "Addition")
    lesson.add_reading(reading)

    lesson.destroy
    #puts "#{lesson.destroyed?}"

    assert lesson.destroyed?
  end

  def test_courses_have_lessons
    lesson = Lesson.new(name: "Math")
    course = Course.new(name: "Math101")

    course.add_lessons(lesson)
    assert "Math", course.lessons.first.name
  end

  def test_destroy_course
    lesson = Lesson.new(name: "Math")
    course = Course.new(name: "Math101")
    course.add_lessons(lesson)

    course.destroy
    assert course.destroyed?
  end

  def test_courses_have_course_instructors
    course = Course.new(name: "Math101")
    instructor1 = CourseInstructor.new(name: "Mr. Anderson")
    course.add_instructor(instructor1)

    assert "Mr. Anderson", course.course_instructors.first.name
  end

  def test_destroy_course
    course = Course.new(name: "Math101")
    instructor1 = CourseInstructor.new(name: "Mr. Anderson")
    course.add_instructor(instructor1)

    course.destroy
    refute course.destroyed?
  end

end
