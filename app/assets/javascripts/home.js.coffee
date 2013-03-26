$.fn.withDate = (date) ->
	@filter ->
		$(this).data('date') == date

$.fn.buildCalendar = () ->
	date = $(@).data('date')
	event = $('.mini_event').withDate("#{date}")
	$(@).append(event);

$ ->

#build calendar
	$('.day_container').each ->
		$(@).buildCalendar();

#build layout
	ins = $('.in')
	invites = $('.invite')
	# if ins.length > 0
	# 	$('#ins_count').html(ins.length);
	# 	$('#insContainer').append(ins);
	# else
	# 	$('#ins_count').html("0");
	# 	$('.ins_arrow').show();

	# if invites.length > 0
	# 	$('#invites_count').html(invites.length);
	# 	$('#invitesContainer').append(invites);
	# else
	# 	$("#noInvites").show();
	# 	$('#invites_count').text("0");
	# 	$('.invites_arrow').show();

	$('#toggleInvites').click ->
		$('#ins').addClass("unselected")
		$('#invites').removeClass("unselected")
		$('#insContainer').hide();
		if invites.length > 0
			$('#invitesContainer').fadeIn();
			$('#invitesContainer').masonry('reload');

	$('#toggleIns').click ->
		$.get '/get_ins',
			id: $('#showInmates').attr('data-slug');
		$('#invites').addClass("unselected")
		$('#ins').removeClass("unselected")
		$('#invitesContainer').hide();
		if ins.length > 0
			$('#insContainer').fadeIn();
			$('#insContainer').masonry('reload');



