
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'test.sqlite3'
)

class School < ActiveRecord::Base
  has_many :terms
  has_many :courses, through: :terms

  default_scope { order('name') }

  def add_term(t)
    terms << t
  end
 


end
