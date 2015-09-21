require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'dev.sqlite3'
)

class Reading < ActiveRecord::Base
  belongs_to :lessons

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
