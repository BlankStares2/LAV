class Term < ActiveRecord::Base
  validates :name, :starts_on, :ends_on, :school_id, presence: true

  default_scope { order('ends_on DESC') }

  scope :for_school_id, ->(school_id) { where("school_id = ?", school_id) }

  def school_name
    school ? school.name : "None"
  end
end
