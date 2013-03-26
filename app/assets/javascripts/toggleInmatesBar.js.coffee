$ ->
	$('#showInmates').click ->
		$.get '/get_intros',
			id: $('#showInmates').attr('data-slug')

		$('.inmates_bar').animate
			left: 0 
			duration: 'slower'
			easing: 'easeOutQuart'
			->	
				$('#showInmates').hide()
				$('#showCalendar').show();;

	$('#showCalendar').click ->
		$('.inmates_bar').animate
			left: -350 
			duration: 'slower'
			easing: 'easeOutQuart'
			->
				$('#showCalendar').hide();	
				$('#showInmates').show();

			
