require 'chronic'

class Suggestion < ActiveRecord::Base
  belongs_to :user
  has_many :events

  CATEGORIES = %w[active creative learning night family] #adventure, culture, community

  acts_as_gmappable :validation => false

  attr_accessible :user_id,
                :starts_at, 
                :duration,
                :ends_at,
                :title, 
                :min, 
                :max,
                :address, 
                :latitude,
                :longitude,
                :chronic_starts_at,
                :chronic_ends_at,
                :link,
                :gmaps,
                :category

  has_attached_file :promo_img, :styles => { :original => '700x700',
                                             :large => '400x400',
                                             :medium => '250x250'},
                             :convert_options => { :original => '-quality 10',
                                                   :medium => '-quality 30' },
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "suggestion/:attachment/:style/:id.:extension",
                             :default_url => "https://s3.amazonaws.com/hoosin-production/suggestion/promo_img/medium/default_promo_img.png"

  validates :max, numericality: { in: 1..10000, only_integer: true }
  validates :min, numericality: { in: 1..10000, only_integer: true }
  # validates :duration, numericality: { in: 0..1000 } 
  validates :title, length: { maximum: 140 }, presence: true
  validates :category, presence: true
  # validates_numericality_of :lng, :lat
  @url = /^((https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?)?$/ 
  validates :link, :format => { :with => @url }

  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :start => starts_at,
      :end => ends_at,
      :host => self.user,
      :gcnt => self.guests.count,
      :tip => self.min,
      :guests => self.guests,
      :tipped => self.tipped
    }
  end

  def start_time
    self.starts_at.strftime "%l:%M%P, %A %B %e"
  end

  def start_date
    self.starts_at.strftime "%A, %B %e"
  end

  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end


  def chronic_starts_at
    self.starts_at
  end

  def chronic_starts_at=(s)
    Chronic.time_class = Time.zone
    self.starts_at = Chronic.parse(s) if s
  end

  def chronic_ends_at
    self.ends_at
  end

  def chronic_ends_at=(e)
    Chronic.time_class = Time.zone
    self.ends_at = Chronic.parse(e) if e
  end

  def ends_at
    if self.duration && self.starts_at
      self.ends_at = self.starts_at + self.duration*3600
    end
  end

  def gmaps4rails_address
    address
  end

  def event_day
    self.starts_at.strftime "%A"
  end
  # can't do here bc doesn't work with time zones...
  # def start_time
  #   starts_at.strftime "%l:%M%P, %A %B %e"
  # end

  def short_event_title
    if self.title.size >=50
      self.title.slice(0..50) + "..."
    else
      self.title
    end
  end
end
