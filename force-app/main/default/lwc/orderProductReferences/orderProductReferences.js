import { LightningElement, api, wire, track } from 'lwc';
import getOrderProducts from '@salesforce/apex/OrderProductReferencesController.getOrderProducts';
import updateRecords from '@salesforce/apex/OrderProductReferencesController.saveRecords';
import { NavigationMixin } from 'lightning/navigation';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent,FlowNavigationFinishEvent  } from 'lightning/flowSupport';

export default class OrderProductReferences extends NavigationMixin(LightningElement) {
    @api orderId;
    @api lstRecords;
    @api referenceMax;
    @track trackedRecords;
    @track isOrder;
    @api objectApiName;

    @wire(getOrderProducts, {recordId: '$orderId'}) 
    wiredOrderProducts ({ error, data }){
        if(data){
            let result = JSON.parse(JSON.stringify(data));

            for(var i = 0; i < result.length; i++){
                result[i].rowNumber = i+1;

                if(Object.hasOwn(result[i], 'CustomerReference__c') == false){
                    result[i].CustomerReference__c = '';
                }
            }

            this.lstRecords = result;
            this.trackedRecords = result;
            console.log('this.trackedRecords on wire:', this.trackedRecords);
        } else if (error){
            console.log("OrderProductReferences LWC ERROR:", error);
            this.trackedRecords = [];
        }
    };    

    connectedCallback(){
        console.log("[MOUNTED]");
        console.log("orderId", this.orderId);
        console.log("wiredOrderProducts", this.wiredOrderProducts);
        console.log("this.objectApiName ", this.objectApiName);

        if(this.objectApiName == 'Opportunity'){
            this.isOrder = false;
        } else {
            this.isOrder = true;
        }

        console.log("this.isOrder ", this.isOrder);
    }

    redirectToOrder(){
        console.log('redirecting... ' + this.orderId);

        // navigate mixin doesnt work because LWC is inside flow
        /*this[NavigationMixin.Navigate]({
            type:'standard__recordPage',
            attributes:{
                recordId: this.orderId,
                actionName: "view"
            }
        });*/

        var navigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigationEvent);
    }

    handleClick(event){
        const buttonLabel = event.target.label;
        console.log('buttonLabel: ' + buttonLabel);

        if(buttonLabel == 'Save'){
            console.log("-- SAVE", JSON.parse(JSON.stringify(this.trackedRecords)));
            var recordsToSave = this.trackedRecords;

            for(var i = 0 ; i < recordsToSave.length; i++){
                delete recordsToSave[i].rowNumber;
            }

            updateRecords({orderProducts : recordsToSave}).then(() => {
                this.redirectToOrder();
            }).catch(err => {
                console.error("[FAILED TO SAVE RECORDS]");
            })
        } else {
            this.redirectToOrder();
        }
    }

    handleAttributeChange(event) {
        console.log('event.id: ', event.target.dataset.recordId);
        console.log('event.detail.value: ', JSON.parse(JSON.stringify(event.detail.value)));
        

        for(var i = 0; i < this.trackedRecords.length; i++){
            if(this.trackedRecords[i].Id == event.target.dataset.recordId){
                this.trackedRecords[i].CustomerReference__c = event.detail.value;
            }
        }

        console.log('this.trackedRecords after change: ', JSON.parse(JSON.stringify(this.trackedRecords)));
        /*const attributeChangeEvent = new FlowAttributeChangeEvent('lstRecords', this.trackedRecords);
        this.dispatchEvent(attributeChangeEvent);*/
    }
}