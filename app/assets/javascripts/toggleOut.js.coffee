$ ->
	$('.out_check').click (e)->
		e.preventDefault();
		$(@).next('.out_text').fadeIn().delay(2000).fadeOut();


