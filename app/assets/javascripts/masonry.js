$(document).ready(function() {
  $('#ideaContainer').imagesLoaded( function(){
    $('#ideaContainer').masonry({
      itemSelector : '.event',
      //column_width: 100
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