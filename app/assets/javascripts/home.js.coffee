$.fn.withDate = (date) ->
	@filter ->
		$(this).data('date') == date

$.fn.buildCalendar = () ->
	date = $(@).data('date')
	event = $('.mini_event').withDate("#{date}")
	$(@).append(event);

$ ->

#build calendar
	$('.day_container').each ->
		$(@).buildCalendar();

#build layout
	ins = $('.in')
	invites = $('.invite')

	$('#toggleInvites').click ->
		$('#ins').addClass("unselected")
		$('#invites').removeClass("unselected")
		$('#insContainer').hide();
		$('#invitesContainer').fadeIn();
		$('#invitesContainer').masonry('reload');

	$('#toggleIns').click ->
		unless $('#insContainer').children().length > 1
			$.get '/get_ins',
				id: $('#showInmates').attr('data-slug');

		$('#invites').addClass("unselected")
		$('#ins').removeClass("unselected")
		$('#invitesContainer').hide();
		$('#insContainer').fadeIn();
		$('#insContainer').masonry('reload');



