
$(document).ready(function () {
    $(".raster_hover").on({
        mouseenter: function (evt) {
            $(this).find('div:first').stop(true, true).show();
        },
        mouseleave: function () {
            $(this).find('div:first').stop(true, false).hide();
        }
    });
});