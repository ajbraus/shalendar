$(document).ready(function() {
  $('#ideaContainer').imagesLoaded( function(){
    $('#ideaContainer').masonry({
      itemSelector : '.sheild',
      isAnimated: true,
    	animationOptions: {
      duration: 200
    	}
    });
  });


  $('.idea_container').imagesLoaded( function(){
    $('.idea_container').masonry({
      itemSelector : '.shield',
      isAnimated: true,
  	 animationOptions: {
      duration: 200
  	 }
    });
  });
});