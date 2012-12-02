$ ->
	$(".meter > span").each ->
		$(@).data("origWidth", $(this).width()).width(0).animate({ width: $(this).data("origWidth") }, 1200);
