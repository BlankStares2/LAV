
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'dev.sqlite3'
)

class Reading < ActiveRecord::Base
  belongs_to :lessons
  validates :order_number, :lesson_id,:url, presence: true
  # validates :url, uniqueness: true
  validates :url, format: { with: /\A(http|https):\/\/\S+/, on: :create }

  default_scope { order('order_number') }

  scope :pre, -> { where("before_lesson = ?", true) }
  scope :post, -> { where("before_lesson != ?", true) }

  def clone
    dup
  end
end
