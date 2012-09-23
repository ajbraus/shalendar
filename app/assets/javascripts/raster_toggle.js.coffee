$.fn.withPicId = (id) ->
	@filter ->
		$(this).data('pic-id') == id

$.fn.withInviterId = (iid) ->
	@filter ->
		$(this).data('inviter-id') == iid

$.fn.withUserId = (uid) ->
	@filter ->
		$(this).data('inviter-id') == uid