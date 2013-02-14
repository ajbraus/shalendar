user = User.last
upcoming_times = []
upcoming_times.push(Event.where('ends_at IS NOT NULL').limit(1))
upcoming_times.push(Event.where('ends_at IS NOT NULL').limit(2))
upcoming_times.push(Event.where('ends_at IS NOT NULL').limit(3))
has_times = true
new_inner_ideas = Event.where('ends_at IS NULL').last(6)
new_inmate_ideas = Event.where('ends_at IS NULL').first(6)
users_new_ideas_count = new_inmate_ideas.count + new_inner_ideas.count
Notifier.digest(user, upcoming_times, has_times, new_inner_ideas, new_inmate_ideas, users_new_ideas_count).deliver