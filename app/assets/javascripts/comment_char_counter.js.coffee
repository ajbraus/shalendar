$ ->
	$('#comment_content').keyup ->
		comment_length = $(@).val().length
		$('#commentCharCount').text(comment_length)
		if comment_length > 200
			$('#commentCharCount').css("color", "#CD0000");
		else
			$('#commentCharCount').css("color", "grey");
		if comment_length > 220
			$('#comment_content').addClass('error');
		else
			$('#comment_content').removeClass('error');