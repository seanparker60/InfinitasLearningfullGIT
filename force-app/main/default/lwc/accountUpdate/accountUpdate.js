import { LightningElement, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import agodiUpdate from '@salesforce/apex/AU_StartAgodiUpdate.start';

export default class AccountUpdate extends LightningElement {

    @track agodiUpdateStarted = false;
    @track rioUpdateStarted = false;

    updateAgodi() {
        this.agodiUpdateStarted = true;
        agodiUpdate();
    }

    updateRIO() {

        this.rioUpdateStarted = true;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'RIO Update',
                message: 'RIO Updates are not yet available!',
                variant: 'error',
            }),
        );
        
    }

}