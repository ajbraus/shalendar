$.fn.withDate = (date) ->
	@filter ->
		$(this).data('date') == date

$.fn.toggleIdeas = (container, path) ->
	open = $('.open')
	ajax = $('#ajaxLoader')
	ajax.show();
	open.hide();
	open.removeClass('open');	
	container.fadeIn();
	container.addClass('open');	
	container.children('.idea_container').masonry('reload');
	if container.children('.idea_container').children().length == 0
		$.get path, 
			id: $('#showInmates').attr('data-slug')
	else
		ajax.hide();

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

	$('#showInvitedIdeas').click ->
		$(@).toggleIdeas($('#invitedIdeasContainer'), '/invited_ideas');
	$('#showInvitedTimes').click ->
		$(@).toggleIdeas($('#invitedTimesContainer'), '/times');
	$('#showIns').click ->
		$(@).toggleIdeas($('#insContainer'), '/ins');
	$('#showPlans').click ->
		$(@).toggleIdeas($('#plansContainer'), '/plans');
	$('#showOuts').click ->
		$(@).toggleIdeas($('#outsContainer'), '/outs');
	$('#showOvers').click ->
		$(@).toggleIdeas($('#oversContainer'), '/overs');
