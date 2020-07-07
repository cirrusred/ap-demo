({
    prepareCreateRecord: function( cmp, event ) {

        let recordFields = {};
        let createRecordEvent = $A.get('e.force:createRecord');
        
        if ( createRecordEvent ) {
            createRecordEvent.setParams({
                'entityApiName': 'Contact',
                'defaultFieldValues': recordFields,
                'panelOnDestroyCallback': function(event) { 
                    //not working since winter19 release, what api version? 
                    //https://success.salesforce.com/ideaView?id=0873A000000Lo16QAC
                    $A.get("e.force:navigateToSObject").setParams({
                        recordId: component.get("v.recordId"),
                        slideDevName: "detail"
                    }).fire();
                    console.log(component.get('v.recordId'));
                }
                
            });
            createRecordEvent.fire();
        }
	},
    
    navigateToUrl: function( url ) {
        
        if ( !$A.util.isEmpty( url ) ) {
            $A.get( 'e.force:navigateToURL' ).setParams({ 'url': url }).fire();
        }
        
    },
        
    enqueueAction: function( component, actionName, params, options ) {
        
        let helper = this;
        
        return new Promise( function( resolve, reject ) {
            
            component.set( 'v.showSpinner', true );
            
            let action = component.get( actionName );
            
            if ( params ) {
                action.setParams( params );
            }
            
            if ( options ) {
                if ( options.background ) { action.setBackground(); }
                if ( options.storable )   { action.setStorable(); }
            }
            
            action.setCallback( helper, function( response ) {
                
                component.set( 'v.showSpinner', false );
                
                if ( component.isValid() && response.getState() === 'SUCCESS' ) {
                    
                    resolve( response.getReturnValue() );
                    
                } else {
                    
                    console.error( 'Error calling action "' + actionName + '" with state: ' + response.getState() );
                    
                    helper.logActionErrors( response.getError() );
                    
                    reject( response.getError() );
                    
                }
            });
            
            $A.enqueueAction( action );
            
        });
    },
    
    logActionErrors : function( errors ) {
        //need to add in additional error handling and display for the user
        //https://developer.salesforce.com/docs/atlas.en-us.lightning.meta/lightning/container_handling_errors.htm
        if ( errors ) {
            if ( errors.length > 0 ) {
                for ( let i = 0; i < errors.length; i++ ) {
                    console.error( 'Error: ' + errors[i].message );
                }
            } else {
                console.error( 'Error: ' + errors );
            }
        } else {
            console.error( 'Unknown error' );
        }
    }
})