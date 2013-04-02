$.fn.withDate = (date) ->
	@filter ->
		$(this).data('date') == date

$.fn.toggleIdeas = (container, path) ->
	open = $('.open')
	ajax = $('#ajaxLoader')
	open.hide();
	open.removeClass('open');	
	container.fadeIn();
	container.addClass('open');	
	unless container.children().length > 0
		$.get path, 
			id: $('#showInmates').attr('data-slug')

# $.fn.buildCalendar = () ->
# 	date = $(@).data('date')
# 	event = $('.mini_event').withDate("#{date}")
# 	$(@).append(event);

$ ->

#build calendar
	# $('.day_container').each ->
	# 	$(@).buildCalendar();

#build layout
	ins = $('.in')
	invites = $('.invite')
	upcoming_times = $('#loadUpcomingTimes').children();

	$('#upcomingTimes').append(upcoming_times);

	$('#showInvitedIdeas').click ->
		$(@).toggleIdeas($('#invitedIdeasContainer'), '/invited_ideas');
	$('#showInvitedTimes').click ->
		$(@).toggleIdeas($('#invitedTimesContainer'), '/invited_times');
	$('#showIns').click ->
		$(@).toggleIdeas($('#insContainer'), '/ins');
	$('#showPlans').click ->
		$(@).toggleIdeas($('#plansContainer'), '/plans');
	$('#showOuts').click ->
		$(@).toggleIdeas($('#outsContainer'), '/outs');
	$('#showOvers').click ->
		$(@).toggleIdeas($('#oversContainer'), '/overs');
