$ ->
	$('#showInmates').click ->
		$('.inmates_bar').animate
			left: 0 
			duration: 'slower'
			easing: 'easeOutQuart'
			->	
				$('#showInmates').hide()
				$('#showCalendar').show();;

	$('#showCalendar').click ->
		$('.inmates_bar').animate
			left: -338 
			duration: 'slower'
			easing: 'easeOutQuart'
			->
				$('#showCalendar').hide();	
				$('#showInmates').show();

			
