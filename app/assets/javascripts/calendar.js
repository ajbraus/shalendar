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
    editable: true, 
    selectable:true,
    selectHelper:true,
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
        color: 'red',
        textColor: 'black',
        ignoreTimezone: true
    },

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
        url: '/my_untipped_invitations',
        color: 'red',
        textColor: '#A3A3A3',
        ignoreTimezone: true
    },

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
    
    // //http://arshaw.com/fullcalendar/docs/event_ui/eventDrop/
    eventDrop: function(event, dayDelta, minuteDelta, allDay, revertFunc){
        updateEvent(event);
    },

    // // http://arshaw.com/fullcalendar/docs/event_ui/eventResize/
    eventResize: function(event, dayDelta, minuteDelta, revertFunc){
        updateEvent(event);
    },

    select: function( startDate, endDate, allDay ) {
        createEvent(startDate, endDate);
    },

    // http://arshaw.com/fullcalendar/docs/mouse/eventClick/
    eventClick: function(event, jsEvent, view){
      // would like a lightbox here.
    },
  });
});

function updateEvent(the_event) {
    $.update(
      "/events/" + the_event.id,
      { event: { 
                 starts_at: "" + the_event.start,
                 ends_at: "" + the_event.end
               }
      }//,
      // function (reponse) { alert('successfully updated task.'); }
    );
};

function createEvent(startDate, endDate) {
    $.create(
        "/events",
        { 
          starts_at: startDate,
          ends_at: endDate
        },
        function (reponse) { alert('successfully created task.'); }
     ); 
};