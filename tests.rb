# Basic test requires
require 'active_record'
require 'minitest/autorun'
require 'minitest/pride'
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
    assignment.lessons << lesson
    assert assignment.id == lesson.pre_class_assignment_id
  end

  def test_school_has_courses_through_terms
    school = School.new(name: "Code")
    course = Course.new(name: "Basket Weaving")
    term = Term.new(name: "Fall")
    school.add_term(term)
    term.add_course(course)
    assert "Basket Weaving", school.courses.name
  end

  def test_validate_lessons_have_names
    lesson = Lesson.new()
    refute lesson.save
  end

  def test_validate_readings_have_order_number_lesson_id_url
    reading = Reading.new()
    refute reading.save
  end

  def test_url_starts_with_reg_expression
    assert Reading.new(url: "http://www.ok.com", lesson_id: 2, order_number: 2)
    book = Reading.new(url: "www.ok.com", lesson_id: 3, order_number: 3)
    refute book.save
    book2 = Reading.new(url: ".com", lesson_id: 4, order_number: 4)
    refute book2.save
    book3 = Reading.new(url: "http://www.ok.com", lesson_id: 2, order_number: 2)
    assert book3.save
  end

  def test_courses_have_code_and_name
    assert Course.new(name: "Math", course_code: "MTH101")
    course = Course.new(course_code: "MATH")
    refute course.save
    course2 = Course.new(name: "brohemionrapsity")
    refute course.save
    course3 = Course.new()
    refute course.save
  end

  def test_course_code_through_terms
    course1 =  Course.create(name: "Math", course_code: "Math101")
    course2 = Course.create(name: "Advanced Functions and Modeling", course_code: "Math101")

    refute course1 == course2
  end

  def test_course_code_three_letters_and_three_numbers
    Course.new(name: "Basket Weaving", course_code: "WEV101")
    beer = Course.new(name: "Brewing", course_code: "369BER")
    refute beer.save
  end

  def test_lessons_have_readings
    lesson = Lesson.new(name: "Math")
    reading = Reading.new(name: "Addition")

    lesson.add_reading(reading)
    assert_equal "Addition", lesson.readings.first.name
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
    assert_equal "Math", course.lessons.first.name
  end

  def test_destroy_course
    lesson = Lesson.new(name: "Math")
    course = Course.new(name: "Math101")
    course.add_lessons(lesson)

    course.destroy
    assert_equal course.destroyed?
  end

  def test_courses_have_course_instructors
    course = Course.new(name: "Math101")
    instructor1 = CourseInstructor.new(name: "Mr. Anderson")
    course.add_instructor(instructor1)

    assert_equal "Mr. Anderson", course.course_instructors.first.name
  end

  def test_destroy_course
    course = Course.new(name: "Math101")
    instructor1 = CourseInstructor.new(name: "Mr. Anderson")
    course.add_instructor(instructor1)

    course.destroy
    refute course.destroyed?
  end

  def test_course_has_readings_through_lessons
    course = Course.new(name: "PE")
    lesson = Lesson.new(name: "Exercise Basics")
    reading = Reading.new(name: "How to do Jumping Jacks")
    course.add_lessons(lesson)
    lesson.add_reading(reading)

    assert "How to do Jumping Jacks", course.readings.name
  end

  def course_has_inclass_assignment
    lesson = Lesson.new(name: "Exercise Basics")
    assignment = Assignment.new(name: "Do 10 Jumping Jacks")
    assignment.lessons << lesson

    assert_equal assignment.id, lesson.in_class_assignment_id
  end

  def test_schools_must_have_name
    school = School.new()
    refute school.save
  end

  def test_terms_have_name_startson_endson_schoolid
    term = Term.new()
    refute term.save
  end

  def test_firstname_lastname_email
    user = User.new(first_name: "Korey", last_name: "Littlewater", email: "koreywithak@littlewater.com")
    assert "Korey", user.first_name
    assert "Littlewater", user.last_name
    assert "koreywithak@littlewater.com", user.email
  end

  def test_user_email_unique
    assert User.new(email: "koreywithak@littlewater.com")

    user_email = User.new(email: "koreywithak@littlewater.com")
    refute user_email.save
  end

  def test_email_has_appropriate_form
    assert User.new(email: "koreywithak@littlewater.com")

    email1 = User.new(first_name: "Jesse", last_name: "Duke", email: "jesse@duke.com")
    email2 = User.new(first_name: "Bo", last_name: "Duke", email: "boduke.com")
    email3 = User.new(first_name: "Luke", last_name: "Duke", email: "luke@@duke.com")
    email4 = User.new(first_name: "Daisy", last_name: "Duke", email: "daisy@dukecom")

    refute email1.save
    refute email2.save
    refute email3.save
    refute email4.save
  end

  def test_users_photo_url
    assert User.new(photo_url: "https://www.photo.com", first_name: "Jesse", last_name: "Duke", email: "jesse@duke.com")

    url1 = User.new(photo_url: "https://www.photo.com", first_name: "Jesse", last_name: "Duke", email: "jesse@duke.com")
    url2 = User.new(photo_url: "www.photo.com", first_name: "Bo", last_name: "Duke", email: "boduke.com")
    url3 = User.new(photo_url: ".com", first_name: "Luke", last_name: "Duke", email: "luke@@duke.com")
    url4 = User.new(photo_url: " ", first_name: "Daisy", last_name: "Duke", email: "daisy@dukecom")

    assert url1.save
    refute url2.save
    refute url3.save
    refute url4.save
  end

  def test_assignments_have_course_id_name_percent_of_grad
    a1 = Assignment.new(course_id: 123, name: "Write essay", percent_of_grade: 10.0)
    a2 = Assignment.new(course_id: 124, name: "Mutliplication")
    a3 = Assignment.new(name: "Science project")

    assert a1.save
    refute a2.save
    refute a3.save
  end

  def test_assignment_name_unique_within_given_courseid
    assign_name1 = Assignment.new(course_id: 123, name: "Art assignment", percent_of_grade: 10.0)
    assign_name2 = Assignment.new(course_id: 123, name: "Spanish test", percent_of_grade: 10.0)
    assign_name3 = Assignment.new(course_id: 123, name: "Art assignment", percent_of_grade: 25.0)

    assert assign_name1.save
    assert assign_name2.save
    refute assign_name3.save
  end

end
