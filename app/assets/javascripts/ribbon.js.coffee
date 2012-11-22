$ ->
	$('#new_idea_blerb').focus ->
		$(@).animate({height: '45px'}, 200);
		$('.btn-new-idea').animate({padding: '23px 12px'}, 200);
	$('#new_idea_blerb').blur ->
		$(@).animate({height: '21px'}, 200);
		$('.btn-new-idea').animate({padding: '11px 12px'}, 200);
