$.fn.withEventId = (id) ->
	@filter ->
		$(this).data('event-id') == id

$.fn.increment = ->
	value = parseInt($(@).text())
	$(@).text(value + 1)

$.fn.decrement = ->
	value = parseInt($(@).text())
	$(@).text(value - 1)

$.fn.rsvp_check = (rsvpCheckHTML) ->
	$(@).addClass('plan')
	$(@).removeClass('idea')
	#$('#littleTIP').remove();
	#$(@).children().off()
	$(@).find('.guest-count').increment()
	$(@).find('.rsvp_check').html(rsvpCheckHTML)
	#$(@).children().on()

$.fn.unrsvp_check = (rsvpCheckHTML) ->
	$(@).addClass('idea')
	$(@).removeClass('plan')
	#$('#littleTIP').remove();
	#$(@).children().off()
	$(@).find('.guest-count').decrement()
	$(@).find('.rsvp_check').html(rsvpCheckHTML)
	#$(@).children().on()