$(function(){
  $('#ideaContainer').masonry({
    itemSelector : '.event',
    isAnimated: true,
    columnWidth: 110,
  	animationOptions: {
    duration: 200
  	}
  });

  $('.idea_container').masonry({
    itemSelector : '.event',
    isAnimated: true,
    columnWidth: 110,
  	animationOptions: {
    duration: 200
  	}
  });
});