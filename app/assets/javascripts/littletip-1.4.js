/*
 *	littleTIP v1.4
 *  <http://code.google.com/p/littletip/>
 *
 *	03JAN2012 © Saulo Santos 
 *  License (requires leaving author name, project link and license link completly intact):
 *  <http://creativecommons.org/licenses/by-sa/3.0/>
 *
 */

	// Configurable options (change value numbers to fit your needs)
	littleTIPdelay			=   0    ;	// Delay time before appear (in pixels)
	littleTIPfade			=   70     ;	// Fading duration time (in pixels)
	littleTIPbackground		=   0.7     ;	// Background opacity (from 0 to 1)
	littleTIPtext			=   1       ;	// Text opacity (from 0 to 1)
	littleTIPx				=   -30      ;	// Horizontal distance from cursor (in pixels)
	littleTIPy				=   -50     ;	// Vertical distance from cursor (in pixels)

	

$(document).ready(function(){			// Script executed on DOM load
	if (navigator.userAgent.match(/Android/i) || navigator.userAgent.match(/webOS/i) || navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i)) {

	}
	else {
	var elT = $("[title]");			// Store all title attributes in a variable for further usage

	elT.mouseover(function(){					// Function applied to title attribute on mouse over
		var elemlT = $(this).attr('title');		// Store title information in a variable for further usage
		this.tip = this.title;					// Copy and expand littleTIP
		this.title = "";						// Remove default tooltip

		$('<div id="littleTIP"><div id="littleTIPtext">'+elemlT+'</div><div id="littleTIPbackground"></div></div>').appendTo('body');	// Create littleTIP class structure
		$('#littleTIP').delay(littleTIPdelay).fadeIn(littleTIPfade).css({		// Delay, fade and littleTIP wrapper css properties
			zIndex: 10000000,
			position: 'absolute',
			display: 'none',
			width: 'auto',
			height: 'auto'
		});
		$('#littleTIP #littleTIPbackground').css({		// littleTIP background css properties
			zIndex: 10000001,
			position: 'absolute',
			display: 'block',
			opacity: littleTIPbackground,
			width: '100%',
			height: '100%',
			top: '0',
			left: '0'
		});
		$('#littleTIP #littleTIPtext').css({		// littleTIP text css properties
			zIndex: 10000002,
			position: 'relative',
			display: 'block',
			opacity: littleTIPtext,
			width: 'auto',
			height: 'auto'
		});
	});



	elT.mousemove(function(e){							// Function applied when mouse moves
		var BwiWi = $(window).width();					// Store window width in a variable for further usage
		var BwiHe = $(window).height();					// Store window height in a variable for further usage
		var BwHs = $(window).scrollLeft();				// Store window horizontal space in a variable for further usage
		var BwVs = $(window).scrollTop();				// Store window vertical space in a variable for further usage
		var liTIP = $('#littleTIP');					// Store littleTIP object in a variable for further usage
		var lTwi = $('#littleTIP').width();				// Store littleTIP width in a variable for further usage
		var lThe = $('#littleTIP').height();			// Store littleTIP height in a variable for further usage

		if (BwiWi + BwHs < e.pageX + lTwi + littleTIPx)	// If window width and window horizontal space is small move littleTIP to the other side
			{
			liTIP.css("left", e.pageX - lTwi - littleTIPx);
			}
		else
			{
			liTIP.css("left", e.pageX + littleTIPx);
			}
		if (BwiHe + BwVs < e.pageY + lThe + littleTIPy)	// If window height and window vertical space is small move littleTIP to the other side
			{
			liTIP.css("top", e.pageY - lThe - littleTIPy);
			}
		else
			{
			liTIP.css("top", e.pageY + littleTIPy);
			}
	});

	elT.mouseout(function(){			// Function applied when mouse moves out
		$('#littleTIP').remove();		// Remove littleTIP
		this.title = this.tip;			// Use default tooltip
	});
	}
});