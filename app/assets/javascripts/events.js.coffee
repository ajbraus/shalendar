$.fn.withEventId (id) ->
	@filter ->
		$(this).data('event-id') == id

$.fn.increment ->
	value = parseInt($(@).text())
	$(@).text(value + 1)

$.fn.decrement ->
	value = parseInt($(@).text())
	$(@).text(value - 1)

$.fn.rsvp_check ->
	$(@).addClass('plan')
	$(@).removeClass('idea')
	$(@).find('.guest-count').increment()