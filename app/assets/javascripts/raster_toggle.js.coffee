$.fn.withPicId = (id) ->
	@filter ->
		$(this).data('pic-id') == id

$.fn.withInviterId = (uid) ->
	@filter ->
		$(this).data('inviter-id') == uid