$.fn.withDate = (date) ->
	@filter ->
		$(this).data('date') == date

$.fn.toggleIdeas = (container, path) ->
	open = $('.open')
	ajax = $('#ajaxLoader')
	unless container.children().length > 0
		ajax.show(0).delay(1300).hide(0);
	open.hide();
	open.removeClass('open');
	if container.children().length > 0
		$('#explanation').hide();
	else
		$('#explanation').show();
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

#build layout
	ins = $('.in')
	invites = $('.invite')

	$('#showInvitedIdeas').click ->
		$(@).toggleIdeas($('#invitedIdeasContainer'), '/invited_ideas');
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