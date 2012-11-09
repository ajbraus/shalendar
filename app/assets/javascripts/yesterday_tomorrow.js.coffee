$ ->
	$.fn.withDate = (date) ->
		@filter ->
			$(this).data('date') == date

	# DATEPICKERDAY
	$('.datePickerDay').click ->
  	pos = $(this).position();
  	$('#datewindow').animate({ left: pos.left - 2 }, 1000);
  	date = $(this).attr('data-date');
  	day_pos = $('dl').withDate(date).position();
  	$('#forecast').animate({ right: day_pos.left }, 1000);

	# YESTERDAY AND TOMORROW
	
	forecast = $('#forecast');


	$('#yesterday').click ->	
		today = $("dl.marker")
		yesterday = $("dl.marker").prev();
		yesterday_pos = yesterday.position();
		if yesterday
			forecast.animate({ right: yesterday_pos.left }, 100); 
			today.removeClass("marker")
			yesterday.addClass("marker")
		return false;

	$('#tomorrow').click ->
		today = $("dl.marker")
		tomorrow = $("dl.marker").next();
		tomorrow_pos = tomorrow.position();
		if tomorrow
			forecast.animate({ right: tomorrow_pos.left }, 100); 
			today.removeClass("marker")
			tomorrow.addClass("marker")
		return false;

	$('#todayButton').click ->
		today = $('dl#today')
		today_pos = today.position();
		forecast.animate({ right: today_pos.left }, 300);
		$('.marker').removeClass('marker')
		today.addClass('marker')
		return false;
