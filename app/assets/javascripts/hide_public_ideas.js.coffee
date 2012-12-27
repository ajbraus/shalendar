$ ->
	$('#hide_public').click ->
		$('.public').fadeToggle();
		$('.public').toggleClass('shield');
		$(@).children().toggleClass('warm_orange');
		$(@).parent().next().find('.idea_container').masonry('reload')
		#$('.public').fadeToggle();
		#$('.public').toggleClass('shield');
		#$('.hide_public').children().toggleClass('warm_orange');
		#$('.idea_container').masonry('reload');