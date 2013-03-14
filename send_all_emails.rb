user = User.last
other_user = User.first
users = User.first(3)
event = Event.last
comment = Comment.last
time = Event.where('starts_at is not null').first
upcoming_times = []
upcoming_times.push(Event.where('ends_at IS NOT NULL').limit(1))
upcoming_times.push(Event.where('ends_at IS NOT NULL').limit(2))
upcoming_times.push(Event.where('ends_at IS NOT NULL').limit(3))
has_times = true
new_inner_ideas = Event.where('ends_at IS NULL').last(6)
new_inmate_ideas = Event.where('ends_at IS NULL').first(6)
users_new_ideas_count = new_inmate_ideas.count + new_inner_ideas.count
Notifier.digest(user, upcoming_times, has_times, new_inner_ideas, new_inmate_ideas, users_new_ideas_count).deliver

Notifier.welcome(user).deliver

Notifier.new_friend(user, other_user).deliver

Notifier.cancellation(event, user).deliver

Notifier.email_comment(comment, user).deliver

Notifier.new_idea(event, user).deliver

Notifier.rsvp_reminder(time, user).deliver

Notifier.time_change(time, user).deliver

Notifier.new_time(time, user).deliver

Notifier.new_rsvp(event, user, other_user).deliver
 
Notifier.follow_up(user, event, users).deliver

Notifier.new_fb_inmate(user, other_user).deliver

Notifier.new_inmate(user, other_user).deliver

Notifier.inmate_invite(user, other_user).deliver
