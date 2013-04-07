$.fn.withDate = (date) ->
	@filter ->
		$(this).data('date') == date

$.fn.toggleIdeas = (container, path) ->
	open = $('.open')
	ajax = $('#ajaxLoader')
	open.hide();
	open.removeClass('open');
	unless container.children().length > 0
		ajax.show();
	container.fadeIn();
	container.addClass('open');
	container.masonry('reload');
	$('.idea_container').imagesLoaded ->
    $('.idea_container').masonry('reload')


# $.fn.buildCalendar = () ->
# 	date = $(@).data('date')
# 	event = $('.mini_event').withDate("#{date}")
# 	$(@).append(event);

$ ->

#build calendar
	# $('.day_container').each ->
	# 	$(@).buildCalendar();

	$('#showInvitedIdeas').click ->
		$('.open').hide();
		$('#invitedIdeasContainer').show();
		$('#invitedIdeasContainer').addClass('open');
		$('#invitedIdeasContainer').masonry('reload');
	$('#showInvitedTimes').click ->
		$(@).toggleIdeas($('#invitedTimesContainer'), '/times');
	$('#showInteresteds').click ->
		$(@).toggleIdeas($('#interestedsContainer'), '/interesteds');
	$('#showIns').click ->
		$(@).toggleIdeas($('#insContainer'), '/ins');
	$('#showOuts').click ->
		$(@).toggleIdeas($('#outsContainer'), '/outs');
	$('#showOvers').click ->
		$(@).toggleIdeas($('#oversContainer'), '/overs');

	$('#showInmates').hover ->
		$('#showInamtes ul li').css('text-decoration','underline');

	$('#help').click ->
		$('.open').hide();
		$('#explanation').fadeIn();
		$("#explanation").addClass('open');