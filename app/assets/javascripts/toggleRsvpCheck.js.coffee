$ ->
	$('.out').click ->
		$(@).parent().siblings().children('.in_check').css("color", "lightgrey");
		$(@).css("color", "#CD0000");

	$('.in_check').click ->
		$(@).parent().siblings().children('.out').css("color", "lightgrey");
		$(@).css("color", "#388EE5");

