# Basic test requires
require 'minitest/autorun'
require 'minitest/pride'

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


  def test_schools_have_terms
    school = School.new(name: "Code")
    term = Term.new(name: "Fall")

    school.add_term(term)

    assert "Fall", school.terms.first.name
  end

  def test_terms_have_courses
    term = Term.new(name: "Fall")
    course = Course.new(name: "Basket Weaving")

    term.add_course(course)

    assert "Backet Weaving", term.courses.first.name
  end

  def test_destroy_term
    term = Term.new(name: "Fall")
    course = Course.new(name: "Basket Weaving")

    term.add_course(course)
     term.destroy
     #puts term.errors.each {|e| puts e}
     refute term.destroyed?
  end

  def test_course_have_students
    student = CourseStudent.new(name: "Pall")
    course = Course.new(name: "Basket Weaving")

    course.add_student(student)

    assert "Pall", course.course_students.first.name
  end

  def test_destroy_course
    student = CourseStudent.new(name: "Pall")
    course = Course.new(name: "Basket Weaving")

    course.add_student(student)

     course.destroy
     #puts term.errors.each {|e| puts e}
     refute course.destroyed?
  end

  def test_course_have_assignments
    assignment = Assignment.new(name: "Homework")
    course = Course.new(name: "Basket Weaving")

    course.add_assignment(assignment)

    assert_equal "Homework", course.assignments.first.name
  end

  def test_destroy_course
    assignment = Assignment.new(name: "Homework")
    course = Course.new(name: "Basket Weaving")

    course.add_assignment(assignment)
     course.destroy
     #puts term.errors.each {|e| puts e}
     assert course.destroyed?
  end

  def test_course_have_pre_class_assignments
    assignment = Assignment.new(name: "Data Entry")
    lesson = Lesson.new(name: "Database")
    lesson2 = Lesson.new(name: "Database2")

    assignment.lessons << lesson2

    assert assignment.id == lesson2.pre_class_assignment_id
  end

  def test_school_has_courses_through_terms
    school = School.new(name: "Code")
    course = Course.new(name: "Basket Weaving")
    term = Term.new(name: "Fall")

    school.add_term(term)
    term.add_course(course)

    assert "Basket Weaving", school.courses.name

  
  end








end
