$ ->
	$('.friend_user').click ->
		# toggle button to friended
		$('#header_friend_count').increment();
		$('#managed_friend_count').increment();
		# construct the friend shield
		# place it in the hoosin friends share div or the friends div on manage friends