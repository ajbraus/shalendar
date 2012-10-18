require 'chronic'

class Suggestion < ActiveRecord::Base
  belongs_to :user
  has_many :events

  CATEGORIES = %w[adventure learn sports kids community shop night] #adventure, culture, community

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
                :category,
                :price,
                :family_friendly,
                :promo_img

  has_attached_file :promo_img, :styles => { :original => '900x700',
                                             :large => '380x520',
                                             :medium => '190x290'},
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "suggestion/:attachment/:style/:id.:extension",
                             :default_url => "https://s3.amazonaws.com/hoosin-production/suggestion/promo_img/medium/default_promo_img.png"

  validates :promo_img, # :attachment_presence => true,
                     :attachment_content_type => { :content_type => [ 'image/png', 'image/jpg', 'image/gif', 'image/jpeg' ] },
                     :attachment_size => { :in => 0..150.kilobytes }

  validates :max, numericality: { in: 1..10000, only_integer: true }
  validates :min, numericality: { in: 1..10000, only_integer: true }
  validates :duration, numericality: { in: 0..1000 }, allow_blank:true
  validates :title, length: { maximum: 140 }, presence: true
  validates :category, presence: true
  validates :price, :format => { :with => /^\d+??(?:\.\d{0,2})?$/ }, :numericality => {:greater_than => 0}, allow_blank:true
  validates_numericality_of :longitude, :latitude, allow_blank:true
  @url = /^((https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?)?$/ 
  validates :link, :format => { :with => @url }, allow_blank:true

  def view_price
    if price == 0
      return "Free"
    else
      return "$#{price}"
    end
  end

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

  def self.event_suggestions(current_user)
    @event_suggestions = []
    @all_event_suggestions = Suggestion.where('starts_at IS NOT NULL and starts_at > ?', Time.now).order('starts_at ASC')
    (-3..16).each do |date_index|
      @suggestions_on_date = []
      @date = Time.now.to_date + date_index.days
      @suggestions_on_date = @all_event_suggestions.select do |es| 
        if current_user.vendor?
          es.starts_at.to_date == @date 
        else 
          es.starts_at.to_date == @date && (!current_user.cloned?(es.id) || !current_user.rsvpd_to_clone?(es.id))
        end
      end
      @event_suggestions.push(@suggestions_on_date)
    end
    return @event_suggestions
            #needs by city
        #@city = current_user.city
        #@event_suggestions = @city.event_suggestions(Time.now.in_time_zone(current_user.time_zone))
        #in city model
        #def event_suggestions(time_now)
        #  silo by vendors in a city
        #  return an array of arrays each one a day 
        #  with the suggestions inside
        #end
  end

  def not_event_suggestions

  end
end
