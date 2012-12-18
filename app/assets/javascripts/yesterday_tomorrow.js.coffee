$.fn.withDate = (date) ->
	@filter ->
		$(this).data('date') == date

$ ->
	
	# DATEPICKERDAY
	$('html, body').scrollTop($('#today').offset().top - 89 );
	$('.datePickerToday').css('color','red')
	$('.datePickerDay').click ->
		pos = $(@).position();
		$('#datewindow').animate({ top: pos.top - 2 }, 500);
		date = $(@).attr('data-date');
		elOffset = $('div').withDate(date).offset().top - 40
		$('html, body').animate({ scrollTop: elOffset }, 'fast', 'swing');
	
	$('#todayButton').click ->
		today = $('#today')
		today_pos = today.offset().top
		$('html, body').animate({ scrollTop: today_pos }, 'fast');
		return false

  	#date = $(this).attr('data-date');
  	#day_pos = $('dl').withDate(date).position();
  	#$('#forecast').animate({ right: day_pos.left }, 1000);

	# YESTERDAY AND TOMORROW
	
	# forecast = $('#forecast');

	# $('#yesterday').click ->	
	# 	today = $("dl.marker")
	# 	yesterday = $("dl.marker").prev();
	# 	yesterday_pos = yesterday.position();
	# 	if yesterday
	# 		forecast.animate({ right: yesterday_pos.left }, 100); 
	# 		today.removeClass("marker")
	# 		yesterday.addClass("marker")
	# 	return false;

	# $('#tomorrow').click ->
	# 	today = $("dl.marker")
	# 	tomorrow = $("dl.marker").next();
	# 	tomorrow_pos = tomorrow.position();
	# 	if tomorrow
	# 		forecast.animate({ right: tomorrow_pos.left }, 100); 
	# 		today.removeClass("marker")
	# 		tomorrow.addClass("marker")
	# 	return false;
