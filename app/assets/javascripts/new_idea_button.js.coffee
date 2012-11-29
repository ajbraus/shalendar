$ ->
	$('#new_idea_blerb').focus ->
		$(@).animate({width: '300px'}, 400);
		# $('.btn-new-idea').animate({right: '100px'}, 200);
	#$('#new_idea_blerb').blur ->
		#$(@).animate({width: '180px'}, 400);
	# 	$('.btn-new-idea').animate({padding: '11px 12px'}, 200);