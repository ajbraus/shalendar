class AddingInstancesToPastOneTimeIdeas < ActiveRecord::Migration
  def change
  	@one_time_ideas = Event.where(one_time: true)
  	@one_time_ideas.each do |i|
	    @parent = Event.create(user_id: i.user.id,
                     city_id: i.city.id,
                     title: i.title,
                     address: i.address,
                     link: i.link,
                     promo_img: i.promo_img,
                     promo_url: i.promo_url,
                     promo_vid: i.promo_vid,
                     friends_only: i.friends_only,
                     family_friendly: i.family_friendly,
                     price: i.price,
                     one_time: true
                  )
	    i.parent_id = @parent.id
	    i.save
  	end
  end
end
