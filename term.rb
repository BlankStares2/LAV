
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)
class Term < ActiveRecord::Base
  has_many :courses, dependent: :restrict_with_error
  belongs_to :school
  validates :name, :starts_on, :ends_on, :school_id, presence: true


  default_scope { order('ends_on DESC') }

  scope :for_school_id, ->(school_id) { where("school_id = ?", school_id) }

  def add_course(c)
    courses << c
  end

  def school_name
    school ? school.name : "None"
  end
end
