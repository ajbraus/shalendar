$(document).ready(function() {

  var date = new Date();
  var d = date.getDate();
  var m = date.getMonth();
  var y = date.getFullYear();
  
  $('#calendar').fullCalendar({
    editable: true,        
    header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
        },
        defaultView: 'agendaWeek',
        height: 550,
        slotMinutes: 30,
        selectable: true,
        
        loading: function(bool){
            if (bool) 
                $('#loading').show();
            else 
                $('#loading').hide();
        },
        
        // a future calendar might have many sources.        
        eventSources: [

        {
            url: '/my_maybes',
            color: 'blue',
            textColor: 'black',
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
            url: '/my_untipped_maybes',
            color: '#DBDBDB',
            textColor: '#A3A3A3',
            ignoreTimezone: true
        },

        {
            url: '/my_untipped_events',
            color: '#BDFFEA',
            textColor: '#A3A3A3',
            ignoreTimezone: true
        },
        
        {
            url: '/my_untipped_plans',
            color: 'lightgreen',
            textColor: 'white',
            ignoreTimezone: true
        }
        ],
        
        timeFormat: 'h:mm t{ - h:mm t} ',
        dragOpacity: "0.5",
        
        // // //http://arshaw.com/fullcalendar/docs/event_ui/eventDrop/
        // eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc){
        // //     updateEvent(event);
        // // },

        // // // http://arshaw.com/fullcalendar/docs/event_ui/eventResize/
        // eventResize: function(event, dayDelta, minuteDelta, revertFunc){
        // //     updateEvent(event);
        // // },

        // http://arshaw.com/fullcalendar/docs/mouse/eventClick/
        eventClick: function(event, jsEvent, view){
          // would like a lightbox here.
        },
  });
});

// function updateEvent(the_event) {
//     $.update(
//       "/events/" + the_event.id,
//       { event: { title: the_event.title,
//                  starts_at: "" + the_event.start,
//                  ends_at: "" + the_event.end,
//                  description: the_event.description
//                }
//       }//,
//       //function (reponse) { alert('successfully updated task.'); }
//     );
// };