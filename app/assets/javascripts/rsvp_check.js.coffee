$.fn.withEventId = (id) ->
	@filter ->
		$(this).data('event-id') == id

$.fn.withSuggestionId = (id) ->
  @filter ->
    $(this).data('suggestion-id') == id

$.fn.increment = ->
	value = parseInt($(@).text())
	$(@).text(value + 1)

$.fn.decrement = ->
	value = parseInt($(@).text())
	$(@).text(value - 1)

$.fn.rsvp_check = (rsvpCheckHTML, rsvpForm, about_to_tip) ->
  $('div#littleTIP').remove();
  $(@).find('#guestCount').eq(0).increment()
  #$(@).find('#guestCount').eq(1).increment()
  $(@).find('.rsvp_check').html(rsvpCheckHTML)
  $(@).find('#rsvpForm').first().html(rsvpForm)
  $(@).find('.status_icon').html("<i class='icon-ok-sign blue' title='you\'re .in'></i>")
  if about_to_tip = 1
    $(@).find("#guestCount").removeClass("not_tipped");
    $(@).find("#eventMin").remove();

