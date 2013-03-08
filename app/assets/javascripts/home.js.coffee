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
	if ins.length > 0
		$('#ins_count').text(ins.length);
		$('#insContainer').append(ins);
	else
		$("#noIns").show();		
		$('#ins_count').text("0");
		$('.ins_arrow').show();

	if invites.length > 0
		$('#invites_count').text(invites.length);
		$('#invitesContainer').append(invites);
	else
		$("#noInvites").show();
		$('#invites_count').text("0");
		$('.invites_arrow').show();


