({
    doInit : function( component, event, helper ) {

        console.log( '*** doInit' );

        component.set('v.flowName', 'Error_Message_Flow_Screen');
        helper.startFlow( component );

    },

    handleFlowStatusChange : function( component, event, helper ) {

        console.log( '*** handleFlowStatusChange' );

        console.log( event.getParams() );

        // customize the flow finish behavior to refresh other components on the page
        // to pick up any data changes performed by the flow
        if ( event.getParam( 'status' ) === 'FINISHED' ) {
            $A.get( 'e.force:refreshView' ).fire();
        }

    },

    handleRecordUpdated : function( component, event, helper ) {

        console.log( '*** handleRecordUpdate' );

        helper.startFlow( component );

    }
})