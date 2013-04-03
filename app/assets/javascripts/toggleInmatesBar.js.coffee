$ ->
	$('#showInmates').click ->
		$('.inmates_bar').show
			effect: 'slide'
			direction: 'left'
			duration: 'slow'
			easing: 'easeOutQuart'
			
	$('#showCalendar').click ->
		$('.inmates_bar').hide
			effect: 'slide'
			direction: 'left'
			duration: 'slow'
			easing: 'easeOutQuart'


			
