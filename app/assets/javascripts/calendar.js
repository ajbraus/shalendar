$(document).ready(function() {

  var date = new Date();
  var d = date.getDate();
  var m = date.getMonth();
  var y = date.getFullYear();
  
  $('#calendar').fullCalendar({       
    header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
    },
    // editable: true, 
    selectable: false,
    selectHelper: false,
    allDaySlot: false,
    defaultView: 'agendaWeek',
    height: 610,
    slotMinutes: 30,
    
    loading: function(bool){
        if (bool) 
            $('#loading').show();
        else 
            $('#loading').hide();
    },
    
    // a future calendar might have many sources.        
    eventSources: [

    {
        url: '/my_invitations',
        color: '#B0FFE7',
        textColor: 'white',
        ignoreTimezone: true
    },

    {
        url: '/my_maybes',
        color: '#B0FFE7',
        textColor: 'white',
        ignoreTimezone: true
    },

    {
        url: '/my_events',
        color: '#33FDC0',
        textColor: 'black',
        ignoreTimezone: true
    },
    
    {
        url: '/my_plans',
        color: '#33FDC0',
        textColor: 'black',
        ignoreTimezone: true
    },

    // Tipping event URLs

    {
        url: '/my_untipped_invitations',
        color: '#F59A9A',
        textColor: 'gray',
        ignoreTimezone: true
    },

    {
        url: '/my_untipped_maybes',
        color: '#F59A9A',
        textColor: 'gray',
        ignoreTimezone: true
    },

    {
        url: '/my_untipped_events',
        color: '#FF264A',
        textColor: 'gray',
        ignoreTimezone: true
    },
    
    {
        url: '/my_untipped_plans',
        color: '#FF264A',
        textColor: 'gray',
        ignoreTimezone: true
    }
    ],
    
    timeFormat: 'h:mm t{ - h:mm t} ',
    dragOpacity: "0.5",
    
    //http://arshaw.com/fullcalendar/docs/event_ui/eventDrop/
    // eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc){
    //     var x=window.confirm("Are you sure you would like to change this event?")
    //     if (x)
    //     updateEvent(event);
    // },

    // // http://arshaw.com/fullcalendar/docs/event_ui/eventResize/
    // eventResize: function(event, dayDelta, minuteDelta, revertFunc){
    //     var x=window.confirm("Are you sure you would like to change this event?")
    //     if (x)
    //     updateEvent(event);
    // },

    select: function( startDate, endDate, allDay ) {
        createEvent(startDate, endDate);
    },

    // http://arshaw.com/fullcalendar/docs/mouse/eventClick/
    eventClick: function(event, jsEvent, view){
        //   var hideDelay = 500;  
        //   var currentID;
        //   var hideTimer = null;

        //   // One instance that's reused to show info for the current person
        //   var container = $('<div id="PopupContainer">'
        //       + '<table width="" border="0" cellspacing="0" cellpadding="0" align="center" class="personPopupPopup">'
        //       + '<tr>'
        //       + '   <td class="corner topLeft"></td>'
        //       + '   <td class="top"></td>'
        //       + '   <td class="corner topRight"></td>'
        //       + '</tr>'
        //       + '<tr>'
        //       + '   <td class="left">&nbsp;</td>'
        //       + '   <td><div id="PopupContent"></div></td>'
        //       + '   <td class="right">&nbsp;</td>'
        //       + '</tr>'
        //       + '<tr>'
        //       + '   <td class="corner bottomLeft">&nbsp;</td>'
        //       + '   <td class="bottom">&nbsp;</td>'
        //       + '   <td class="corner bottomRight"></td>'
        //       + '</tr>'
        //       + '</table>'
        //       + '</div>');

        //   $('body').append(container);

        //   $('.PopupTrigger').live('mouseover', function()
        //   {
        //       // format of 'rel' tag: pageid,personguid
        //       var settings = $(this).attr('rel').split(',');
        //       var pageID = settings[0];
        //       currentID = settings[1];

        //       // If no guid in url rel tag, don't popup blank
        //       if (currentID == '')
        //           return;

        //       if (hideTimer)
        //           clearTimeout(hideTimer);

        //       var pos = $(this).offset();
        //       var width = $(this).width();
        //       container.css({
        //           left: (pos.left + width) + 'px',
        //           top: pos.top - 5 + 'px'
        //       });

        //       $('#PopupContent').html('&nbsp;');

        //       $.ajax({
        //           type: 'GET',
        //           url: 'event_path',
        //           data: 'page=' + pageID + '&guid=' + currentID,
        //           success: function(data)
        //           {
        //               // Verify that we're pointed to a page that returned the expected results.
        //               if (data.indexOf('personPopupResult') < 0)
        //               {
        //                   $('#PopupContent').html('<span >Page ' + pageID + ' did not return a valid result for person ' + currentID + '.<br />Please have your administrator check the error log.</span>');
        //               }

        //               // Verify requested person is this person since we could have multiple ajax
        //               // requests out if the server is taking a while.
        //               if (data.indexOf(currentID) > 0)
        //               {                  
        //                   var text = $(data).find('.personPopupResult').html();
        //                   $('#PopupContent').html(text);
        //               }
        //           }
        //       });

        //       container.css('display', 'block');
        //   });

        //   $('.PopupTrigger').live('mouseout', function()
        //   {
        //       if (hideTimer)
        //           clearTimeout(hideTimer);
        //       hideTimer = setTimeout(function()
        //       {
        //           container.css('display', 'none');
        //       }, hideDelay);
        //   });

        //   // Allow mouse over of details without hiding details
        //   $('#PopupContainer').mouseover(function()
        //   {
        //       if (hideTimer)
        //           clearTimeout(hideTimer);
        //   });

        //   // Hide after mouseout
        //   $('#PopupContainer').mouseout(function()
        //   {
        //       if (hideTimer)
        //           clearTimeout(hideTimer);
        //       hideTimer = setTimeout(function()
        //       {
        //           container.css('display', 'none');
        //       }, hideDelay);
        //   });
        // });
    }

    // dayClick: function(date, allDay, jsEvent, view) {
    //     // alert('Clicked on the slot: ' + date);
    //     // alert('Coordinates: ' + jsEvent.pageX + ',' + jsEvent.pageY);   
    //     // alert('Current view: ' + view.name);

    // // change the day's background color just for fun
    // $(this).css('background-color', 'blue');
    // },
  });
});

// function updateEvent(the_event) {
//     $.update(
//       "/events/" + the_event.id,
//       { event: { 
//                  starts_at: "" + the_event.start,
//                  ends_at: "" + the_event.end
//                }
//       }//,
//       // function (reponse) { alert('successfully updated task.'); }
//     );
// };

// function createEvent(startDate, endDate) {
//     $.create(
//         "/events",
//         { 
//           starts_at: startDate,
//           ends_at: endDate
//         },
//         function (reponse) { alert('successfully created event.'); }
//      ); 
// };