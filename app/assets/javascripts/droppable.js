// $(function() {
//     // there's the idea_container and the sidebar
//     $ideaContainer = $( ".idea_container" ),
//     $sidebar = $( ".sidebar" );

//     // let the ideaContainer items be draggable
//     $( ".event", $ideaContainer ).draggable({
//         cancel: ".rsvp_check", // clicking an icon won't initiate dragging
//         revert: "invalid", // when not dropped, the item will revert back to its initial position
//         containment: "document",
//         helper: "clone",
//         cursor: "move"
//     });

//     // let the sidebar be droppable, accepting the ideaContainer items
//     $sidebar.droppable({
//         accept: ".idea_container > .event",
//         activeClass: "ui-state-highlight",
//         drop: function( event, ui ) {
//             deleteImage( ui.draggable );
//         }
//     });

//     // let the ideaContainer be droppable as well, accepting items from the sidebar
//     $ideaContainer.droppable({
//         accept: ".sidebar .event",
//         activeClass: "custom-state-active",
//         drop: function( event, ui ) {
//             recycleImage( ui.draggable );
//         }
//     });

//     // image deletion function
//     var recycle_icon = "<a href='link/to/recycle/script/when/we/have/js/off' title='Recycle this image' class='ui-icon ui-icon-refresh'>Recycle image</a>";
//     function deleteImage( $item ) {
//         $item.fadeOut(function() {
//             var $list = $( "ul", $sidebar ).length ?
//                 $( "ul", $sidebar ) :
//                 $( "<ul class='ideaContainer ui-helper-reset'/>" ).appendTo( $sidebar );

//             $item.find( "a.ui-icon-sidebar" ).remove();
//             $item.append( recycle_icon ).appendTo( $list ).fadeIn(function() {
//                 $item
//                     .animate({ width: "48px" })
//                     .find( "img" )
//                         .animate({ height: "36px" });
//             });
//         });
//     }

//     // // image preview function, demonstrating the ui.dialog used as a modal window
//     // function viewLargerImage( $link ) {
//     //     var src = $link.attr( "href" ),
//     //         title = $link.siblings( "img" ).attr( "alt" ),
//     //         $modal = $( "img[src$='" + src + "']" );

//     //     if ( $modal.length ) {
//     //         $modal.dialog( "open" );
//     //     } else {
//     //         var img = $( "<img alt='" + title + "' width='384' height='288' style='display: none; padding: 8px;' />" )
//     //             .attr( "src", src ).appendTo( "body" );
//     //         setTimeout(function() {
//     //             img.dialog({
//     //                 title: title,
//     //                 width: 400,
//     //                 modal: true
//     //             });
//     //         }, 1 );
//     //     }
//     // }

//     // // resolve the icons behavior with event delegation
//     // $( "ul.ideaContainer > li" ).click(function( event ) {
//     //     var $item = $( this ),
//     //         $target = $( event.target );

//     //     if ( $target.is( "a.ui-icon-sidebar" ) ) {
//     //         deleteImage( $item );
//     //     } else if ( $target.is( "a.ui-icon-zoomin" ) ) {
//     //         viewLargerImage( $target );
//     //     } else if ( $target.is( "a.ui-icon-refresh" ) ) {
//     //         recycleImage( $item );
//     //     }

//     //     return false;
//     // });
// });