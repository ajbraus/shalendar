$.fn.withPicId = (id) ->
  @filter ->
    $(this).data('pic-id') == id

$.fn.withInviterId = (iid) ->
  @filter ->
    $(this).data('inviter-id') == iid

$.fn.withUserId = (uid) ->
  @filter ->
    $(this).data('user-id') == uid
    
$.fn.withEventId = (id) ->
	@filter ->
		$(this).data('event-id') == id

$.fn.increment = ->
	value = parseInt($(@).text())
	$(@).text(value + 1)

$.fn.decrement = ->
	value = parseInt($(@).text())
	$(@).text(value - 1)
	
$.fn.rsvp_check = (rsvpCheckHTML, rsvpForm) ->
  $('div#littleTIP').remove();
  $(@).find('#guestCount').eq(0).increment()
  #$(@).find('#guestCount').eq(1).increment()
  $(@).find('.rsvp_check').first().html(rsvpCheckHTML)
  $(@).find('#rsvpForm').first().html(rsvpForm);
  $(@).find('#rsvpForm').first().addClass('rsvp_blue');
  $(@).find('button.out').first().remove();
  $(@).find('.status_icon').html("<i class='icon-ok-sign blue' title='you\'re .in'></i> you're .in")    

