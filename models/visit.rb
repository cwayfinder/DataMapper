class Visit
  include DataMapper::Resource

  property :id, Serial # An auto-increment integer key
  property :created_at, DateTime # A DateTime, for any date you might like.

  belongs_to :user
end
