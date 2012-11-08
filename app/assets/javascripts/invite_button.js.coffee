$ ->
	$('.invite_button').click ->
		friend = $(@).parent().parent().parent();
		$('#invites').append(friend);
		$('#invite_count').increment();