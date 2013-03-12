$ ->
	$('.out').click ->
		$(@).parent().siblings().children('.in_check').css("color", "lightgrey")
		$(@).css("color", "#CD0000");
		$(@).parent().parent().siblings('#status').html("out")

	$('.in_check').click ->
		$(@).parent().siblings().children('.out').css("color", "lightgrey")
		$(@).css("color", "#388EE5");
		$(@).parent().parent().siblings('#status').html(".interested")

# 	$('.out_check').click (e)->
# 		e.preventDefault();
# 		if $('.in_text').length > 1
# 			$('.in_text').hide();
# 		$(@).next('.out_text').fadeIn().delay(2000).fadeOut();

# 	$('.in_check').click (e)->
# 		e.preventDefault();
# 		if $('.out_text').length > 1
# 			$('.out_text').hide();
# 		$(@).next('.in_text').fadeIn().delay(2000).fadeOut();

