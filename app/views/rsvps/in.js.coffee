#IF RSVP FROM LAYinterested
#rsvp to itself in toggleRsvpCheck.js.coffee

$ ->
	#idea ('.idea')
	idea = $('div.idea').withEventId(<%= @event.id %>)

	#.invites ('.invite')
	invite = $('div.invite').withEventId(<%= @event.id %>)

	if invite != []
		interested = invite.find('.in_check')
		# $('#invited_times_count').decrement();
	else if idea != []
		interested = idea.find('.in_check')
		# $('#invited_ideas_count').decrement();

	interested.parent().siblings().children('.out').css("color", "lightgrey");
	interested.css("color", "#388EE5");

	# if I want to make event#show ajaxy
	# $('#rsvpForm').html("<%= escape_javascript(render partial: 'events/rsvp_form', object: @event, as: :event) %>")

	afterRsvpLightbox = $('#shareAfterRsvp')
	afterRsvpLightbox.html("<%= escape_javascript(render partial: 'shared/share_after_rsvp', object: @event, as: :event) %>")
	afterRsvpLightbox.fadeIn();
	$('#overlay').fadeIn();

	$('#close').click ->
		afterRsvpLightbox.fadeOut();
		$('#overlay').fadeOut();

	$('body').click ->
	  afterRsvpLightbox.fadeOut();
	  $('#overlay').fadeOut();

	$('.share_after_rsvp').children().click (event) ->
		event.stopPropagation();

#  $("a[href$='new_invited_events']").click(function(event){
#       event.stopPropagation();
#       $('#new_invited_events_count').text('0').hide();
#  });

<% if false %>
#don't rsvp to instances unless it is a one_time idea
<% if @event.one_time? %>
	<% @event.instances.each do |i| %> 
		time = $('.instance').withEventId(<%= i.id %>)
		time.find('.mini_in_interested').first().html("<div class='in_on_instance'><i class='icon-ok blue' title='you're .in'></i> .in</div>")
		time.find('a').first().removeClass('not_rsvpd');

		#if instances weren't there - but they are
		#$('.day_container').withDate(<%= "#{i.starts_at.to_date}" %>)
		#day.append("<%= escape_javascript (render partial: 'users/mini_event', object: i, as: :event) %>")
	<% end %>
<% end %>

# IF RSVPING FROM CALENDAR
# rsvp to itself in the calendar 
	time = $('.instance').withEventId(<%= @event.id %>)
	# time.rsvp_check("<%= escape_javascript(render partial: 'users/rsvp_check', object: @event, as: :event) %>", '' ); 
	time.find('.mini_in_interested').first().html("<div class='in_on_instance'><i class='icon-ok blue' title='you're .in'></i> .in</div>")
	time.find('a').first().removeClass('not_rsvpd');

# rsvp to its parent in layinterested if present
<% @parent = @event.parent %>
<% if @parent.present? %>	
	parent = $('.event').withEventId(<%= @parent.id %>)
	parent.find('.interested').css("color", "lightgrey")
	parent.find('.in_check').css("color", "#388EE5");
	parent.find('#status').html(".interested")
	parent.find('#timeStatus').html("<a href='/ideas/<%= @event.slug %>/new_time'><div class='add_time fadeInGreen'><i class='icon-time'></i> suggest new time</div>")
<% end %>

event = $('.event').withEventId(<%= @event.id %>)
event.find('#timeStatus').html("<a href='/ideas/<%= @event.slug %>/new_time'><div class='add_time fadeInGreen'><i class='icon-time'></i> suggest new time</div>");
event.find('.in_check').click ->
	$(this).preventDefault();

<% if @event.starts_at.present? %>
$('#ins_count').increment();
$('#invited_times_count').decrement();
<% else %>
$('#interesteds_count').increment();
$('#invites_count').decrement();
<% end %>
# if invited_time
<% end %>
