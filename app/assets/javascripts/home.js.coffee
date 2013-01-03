$.fn.toggleIdeas = (show, hide) ->
	#update header
	unless $(@).hasClass('bold')
		$(@).addClass("bold");
	$(@).siblings().removeClass("bold")
	#hide elements
	$(hide).hide();
	$(hide).removeClass('event');
	#show elements
	$(show).addClass('event');
	$(show).fadeIn();
	#reload idea containers
	$('#ideaContainer').masonry('reload');
	$('.idea_container').masonry('reload');

$.fn.toggleAll = () ->
	unless $(@).hasClass('bold')
		$(@).addClass("bold");
	$(@).siblings().removeClass("bold")
	
	$('.shield').addClass('event').show();
	$('#ideaContainer').masonry('reload');
	$('.idea_container').masonry('reload');

# $.fn.showCalendar = () ->
# 	$(@).css('color','#EB8325');
# 	$('#ideaContainer').hide();
# 	$('#timesCalendar').fadeIn();
	# days = $('.idea_container')
	# connectDatesTo times for day in days
	# 	date = day.attr('date')

	# 	append each shield.withDate to that div.idea_container withDate
	# $('div').withDate()


$ ->
	$('#jrIdeas').click ->
		$(@).toggleIdeas('.shield:hidden', null);
	$('#jrPlans').click ->
		$(@).toggleIdeas('.rsvpd', 'div.shield:not(.rsvpd)');
	$('#jrFriendsIdeas').click ->
		$(@).toggleIdeas('.invited', 'div.shield:not(.invited)');
	$('#jrMine').click ->
		$(@).toggleIdeas('.mine', 'div.shield:not(.mine)');
	$('#jrCityIdeas').click ->
		$(@).toggleIdeas('.public', 'div.shield:not(.public)');

	$('#jrCalendar').click ->
		$(@).showCalendar();



# $ ->
# 	$('#hide_public').click ->
# 		$('.public').fadeToggle();
# 		$('.public').toggleClass('shield');
# 		$(@).children().toggleClass('warm_orange');
# 		$(@).parent().next().find('.idea_container').masonry('reload')
		#$('.public').fadeToggle();
		#$('.public').toggleClass('shield');
		#$('.hide_public').children().toggleClass('warm_orange');
		#$('.idea_container').masonry('reload');