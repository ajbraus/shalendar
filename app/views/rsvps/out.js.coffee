# change the x to red (toggleRsvpCheck.js.coffee)
$ ->
	#idea ('.idea')
	idea = $('div.idea').withEventId(<%= @event.id %>)
	#.invites ('.invite')
	invite = $('div.time').withEventId(<%= @event.id %>)

	if invite != []
		out = invite.find('.out')
		# $('#invited_times_count').decrement();
	else if idea != []
		out = idea.find('.out')
		# $('#invited_ideas_count').decrement();

	out.parent().siblings().children('.in_check').css("color", "lightgrey");
	out.css("color", "#CD0000");

	# if rsvping out of an upcomming in
	$('.instance').withEventId(<%= @event.id %>).find('.mini_in_out').first().html("<div class='in_on_instance'><i class='icon-remove red' title='you're out'></i> out</div>")
	# show user is out of any .instances of the idea from the mini_calendar
	<% @event.instances.each do |i| %>
		$('.instance').withEventId(<%= i.id %>).find('.mini_in_out').first().html("<div class='in_on_instance'><i class='icon-remove red' title='you're out'></i> out</div>")
	<% end %>


