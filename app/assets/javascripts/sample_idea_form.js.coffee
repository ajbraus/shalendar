$('#new_idea_title').bind "change keyup", (event) ->
	title = $(@).text();
	$('#eventTitle').text(title);

