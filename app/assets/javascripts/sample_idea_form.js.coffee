$ ->
	#TOGGLING
	# $.fn.slideUpslideDown = (el) ->
	# 	if el.hasClass("open")
	# 		el.slideUp();
	# 		el.removeClass("open");
	# 	else
	# 		$('.open').slideUp();
	# 		$('.open').removeClass("open");
	# 		el.slideDown();
	# 		el.addClass("open");
	# 		el.css("color", "#EB8325")

	#TITLES
	$('#new_idea_title').keyup ->
		title = $(@).val().substring(0,60);
		title_length = $(@).val().length
		$('.eventTitle').text(title);
		$('#titleCharCount').text(title_length)
		if title_length > 50
			$('#titleCharCount').css("color", "#CD0000");
		else
			$('#titleCharCount').css("color", "black");
		if title_length > 60
			$('#new_idea_title').addClass('error');
		else
			$('#new_idea_title').removeClass('error');

	#DESCRIPTION
	$('#new_idea_description').keyup ->
		description = $(@).val();
		$('#eventDescription').text(description);

	#STARTS AT
	$('.starts_at').blur ->
		datetime = $(@).val();
		$('.eventStartsAt').text(datetime);
	#DURATION
	$('#event_duration').keyup ->
		duration = $(@).val();
		$('.eventDuration').text(" (#{ duration } hrs)");

	$('#expandOptions').click ->
		$('#advancedOptions').toggle();

	#CITY-WIDE IDEAS
	$('#isPublic').click ->
  	$("#addcategoriesp").fadeToggle();
  	$('.category_radio').addClass("required");
  	$('#eventPublicIcon').toggle();
  	$('.group_button').toggle();
	
	#CATEGORY
	$('#categories > select').change ->
		text = $('#categories > select option:selected').text();
		if text == "Please select"
			text = ''
		$('#eventCategory').text(text);

	#TIPPING POINT
	$('#event_min').keyup ->
		min = $(@).val();
		if min > 1
			$('#eventMin').text("/#{ min }");
			proportion = 100*1/min
			$('.meter').addClass("animate orange");
			$('.meter > span').css('width', "#{proportion}%");
		if min < 2
			$('#eventMin').empty();
			$('.meter').removeClass("animate orange");
			$('.meter >span').css('width', '100%');
		if min > 99
			$('.eventIsBigIdea').show();
		if min < 99
			$('.eventIsBigIdea').hide();

	#ADDRESS
	$('#event_address').keyup ->
		address = $(@).val();
		$('#eventLocation').text(" " + address);
	#LINK
	$('#event_link').keyup ->
		link = $(@).val();
		short_link = $(@).val().substr(0,15) + "..." ;
		if link.length < 16
			$('#eventLink').text(" " + link)
		else 
			$('#eventLink').text(" " + short_link)
	#COST
	$('#event_price').keyup ->
		cost = $(@).val();
		$('#eventCost').text(" $ #{cost}")
	#FAMILYFRIENDLY
	$('.family_friendly_checkbox .switch').click ->
		$('#eventFamilyFriendlyIcon').toggle();

	#URL PIC
	$('#event_promo_url').keyup ->
		if $('#event_promo_url').val().length > 0
			pic_url = $('#event_promo_url').val();
			img = "<img src=#{ pic_url } />"
			$('#eventImage').html(img);
			$('#eventPromoImg').html(img);
		if $('#event_promo_url').val().length < 1
			$('#eventImage').empty();
			$('#eventPromoImg').empty();

	#UPLOAD PIC - USING A PLACEHOLDER BECAUSE CAN't GET IT TO WORK
	$("#event_promo_img").change (e) ->
		# fileList = e.target.files
		# if fileList[0].type.match(/image.*/)
		# 	fileName = fileList[0].name
		sampleImg = "<img src='http://lorempixel.com/400/300/abstract/placeholder image/' />"
		#sampleImg = "<img src='http://placehold.it/350x150/EEEEEE/D1CDCD/&text=placeholder' />"
		$('#eventPromoImg').html(sampleImg);
		$('#eventImage').html(sampleImg);

	# uploadButton = $("#event_promo_img");
	# uploadButton.uploadPreview (file, event) ->
	#   img = $ "<img/>",
	#     alt: file.name
	#     src: event.target.result
	#     title: file.name
	#   $(this).append img

	#YOUTUBE VIDEO
	$('#event_promo_vid').keyup ->
		sampleImg = "<img src='/assets/youtube_plcholder.png' />"
		$('#eventVid').html(sampleImg);
		if $(@).val().length > 0
			$('#eventVideoIcon').show();
		else 
			$('#eventVideoIcon').hide();



