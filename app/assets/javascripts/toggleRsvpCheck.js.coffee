$ ->
	$('.out_check').click (e)->
		e.preventDefault();
		if $('.in_text').length > 1
			$('.in_text').hide();
		$(@).next('.out_text').fadeIn().delay(2000).fadeOut();

	$('.in_check').click (e)->
		e.preventDefault();
		if $('.out_text').length > 1
			$('.out_text').hide();
		$(@).next('.in_text').fadeIn().delay(2000).fadeOut();

