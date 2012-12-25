$.fn.disableEnter = (e) ->
	if e.which == 13
		return false;

$ ->
	$('#new_idea_title').keypress (e) ->
		$(@).disableEnter(e);