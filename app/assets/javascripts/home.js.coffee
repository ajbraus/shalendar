$.fn.withDate = (date) ->
	@filter ->
		$(this).data('date') == date

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

	$('#toggleInvites').click ->
		$('#insContainer').hide();
		$('#invitesContainer').fadeIn();
		$('#invitesContainer').masonry('reload');

	$('#toggleIns').click ->
		$('#invitesContainer').hide();
		$('#insContainer').fadeIn();
		$('#insContainer').masonry('reload');



