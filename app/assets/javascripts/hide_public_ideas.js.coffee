$ ->
	$('.hide_public').click ->
		#$(@).parent().next().find('.public').fadeToggle();
		#$(@).parent().next().find('.public').toggleClass('shield');
		$('.public').fadeToggle();
		$('.public').toggleClass('shield');
		#$(@).children().toggleClass('warm_orange');
		$('.hide_public').children().toggleClass('warm_orange');
		#$(@).parent().next().find('.idea_container').masonry('reload')
		$('.idea_container').masonry('reload');