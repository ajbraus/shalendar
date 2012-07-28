var mouseX;
var mouseY;
$(document).mousemove( function(e) {
   mouseX = e.pageX - 550; 
   mouseY = e.pageY - 100;
}); 

$(document).ready(function () {
    $(".raster_hover").on({
        mouseenter: function () {
            $(this).find('div:first').stop(true, true).css({'top':mouseY,'left':mouseX}).show();
        },
        mouseleave: function () {
            $(this).find('div:first').stop(true, false).hide()
        }
    });
});