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
	$(show).show();
	$('#ideaContainer').masonry('reload');
	$('.idea_container').masonry('reload');
	#reload idea containers

$.fn.buildCalendar = () ->
	date = $(@).data('date')
	event = $('.event').withDate("#{date}") 
	$(@).append(event);
	$(@).masonry({
		itemSelector : '.event',
		isAnimated: true,
		animationOptions: { duration: 100 } })

$.fn.showCalendar = () ->
	$(@).toggleClass("warm_orange")
	if $('#timesCalendar').is(':hidden')
		$('#ideaContainer').hide();
		$('#timesCalendar').fadeIn();
		$('.idea_container').each ->
			$(@).buildCalendar();	
	else
		$('#timesCalendar').hide();
		$('#ideaContainer').fadeIn();
		$("#ideaContainer").masonry('reload')

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
