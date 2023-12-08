import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import CONTACT_FIELD from '@salesforce/schema/Lead.Contact__c';
import getContacts from '@salesforce/apex/CS_contactSelectorHelper.returnContacts';
import contactSelection from '@salesforce/apex/CS_contactSelectorHelper.markForContactSelection';
import setContactToLead from '@salesforce/apex/CS_contactSelectorHelper.updateLead';

const fields = [CONTACT_FIELD];

export default class ContactSelector extends LightningElement {

    @api recordId;
    @api contacts = [];
    @api selectedContactId;

    contact = null;
    @track Title = 'We found multiple possible Contact matches, please select the correct Contact';
    @track finished = false;
    @track selectedRows = [];
    @track showElement = false;
    @track contactRecords = [];
    @track columns =[
        {
            label: 'First Name',
            fieldName: 'contactUrl',
            type: 'url',
            typeAttributes: {label: {fieldName: 'FirstName'},
            target: '_self'}
        },
        {
            label: 'Last Name',
            fieldName: 'contactUrl',
            type: 'url',
            typeAttributes: {label: {fieldName: 'LastName'},
            target: '_self'}
        },
        {
            label: 'Email',
            fieldName: 'Email',
            type: 'email'
        },
        {
            label: 'Account Name',
            fieldName: 'AccountUrl',
            type: 'url',
            typeAttributes: {label: {fieldName: 'AccountName'},
            target: '_self'}
        }
    ];

    @wire(getRecord, {recordId: '$recordId', fields: [CONTACT_FIELD]})
    lead;

    @wire(getContacts, { "recordId": '$recordId' })
    wiredContacts({ error, data }) {

        console.log('RecordId = ' + this.recordId);

        if (data) {
            console.log('we have data');
            
            let d = [];
            data.forEach(element => {
                let elt = [];
                elt.Id = element.Id;
                elt.contactUrl = `/${element.Id}`
                elt.FirstName = element.FirstName;
                elt.LastName = element.LastName;
                elt.Email = element.Email;
                if (element.AccountId) {
                    elt.AccountName = element.Account.Name;
                    elt.AccountUrl = `/${element.AccountId}`;
                } else {
                    elt.AccountName = '';
                    elt.AccountUrl = '';
                }
                d.push(elt);
            })
            this.contactRecords = d;

            this.contact = this.lead.data.fields.Contact__c.value;

            console.log('contact = ' + this.contact);

            if (this.contactRecords.length > 0 && this.contact == null) {
                contactSelection({ recordId: this.recordId });
                this.showElement = true;
                if (this.contactRecords.length === 1) {
                    this.Title = 'We have found a possible Contact match, please Select the Contact if this is a correct match'
                }
            }
            console.log('showElement = ' + this.showElement);

        } else if (error) {
            console.log(error);
        } else {
            console.log('We do not have data');
        }
    }

    selectContact(){
        var selectedRecord = this.template.querySelector("lightning-datatable").getSelectedRows();
        this.selectedContactId = selectedRecord.Id;

        if (selectedRecord.length > 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select only one Contact.',
                    variant: 'error',
                }),
            );
        } else if (selectedRecord.length == 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a Contact first.',
                    variant: 'error',
                }),
            );
        } else {
            console.log('Assigning Contact with Id ' + selectedRecord[0].Id + ' to lead with Id ' + this.recordId);
            setContactToLead({leadId: this.recordId, contactId: selectedRecord[0].Id});
            this.finished = true;
            this.showElement = false;
            updateRecord({ fields: { Id: this.recordId } });
        }
    }
    
}