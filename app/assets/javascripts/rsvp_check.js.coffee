$.fn.withEventId = (id) ->
	@filter ->
		$(this).data('event-id') == id

$.fn.increment = ->
	value = parseInt($(@).text())
	$(@).text(value + 1)

$.fn.decrement = ->
	value = parseInt($(@).text())
	$(@).text(value - 1)

$.fn.rsvp_check = (rsvpCheckHTML, about_to_tip) ->
  $(@).find('#guestCount').eq(0).increment()
  $(@).find('#guestCount').eq(1).increment()
  $(@).find('.rsvp_check').html(rsvpCheckHTML) 
  if $(@).hasClass("not_rsvpd")
    $(@).removeClass("not_rsvpd")
    $(@).addClass("rsvpd")
  if about_to_tip = 1
    $(@).find("#guestCount").removeClass("red");
    $(@).find("#eventMin").remove();
