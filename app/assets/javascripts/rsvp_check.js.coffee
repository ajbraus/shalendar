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
  $(@).find('.count').increment()
  $(@).find('.rsvp_check').html(rsvpCheckHTML) 
  if $(@).hasClass("tipped_not_rsvpd")
    $(@).removeClass("tipped_not_rsvpd")
    $(@).addClass("tipped_rsvpd")
  else if about_to_tip = 1
    $(@).removeClass("not_tipped_not_rsvpd")
    $(@).addClass("tipped_rsvpd")
  else if $(@).hasClass("not_tipped_not_rsvpd")
    $(@).removeClass("not_tipped_not_rsvpd")
    $(@).addClass("not_tipped_rsvpd")
  

$.fn.unrsvp_check = (rsvpCheckHTML) ->
  $(@).find('.count').decrement()
  $(@).find('.rsvp_check').html(rsvpCheckHTML)
  if $(@).hasClass("tipped_rsvpd")
    $(@).removeClass("tipped_rsvpd")
    $(@).addClass("tipped_not_rsvpd")
  else
    $(@).removeClass("not_tipped_rsvpd")
    $(@).addClass("not_tipped_not_rsvpd")


#if next plan remove that and add it to real next plan
#if needs one more to tip then switch to tipped classes