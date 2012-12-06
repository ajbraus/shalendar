$ ->
	if navigator.userAgent.match(/Android/i) || navigator.userAgent.match(/webOS/i) || navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i)
		$('#in').toggle();
		#$('#flakeOut')toggle();
	else
		$('#inButton').hover ->
			$('#in').toggle();
			$('#flakeOut').toggle();