class Categorization < ActiveRecord::Base
  attr_accessible :category_id, :event_id
  belongs_to :category
  belongs_to :event
end