import { LightningElement, track, wire, api } from 'lwc';
import uId from '@salesforce/user/Id';

import getBaseAttributes from '@salesforce/apex/CON_contactFilterHelper.setBaseClassificationAttributes';
import getBaseAttributeValues from '@salesforce/apex/CON_contactFilterHelper.setBaseClassificationAttributeValues';
import getAttributeValuesBasedOnAttribute from '@salesforce/apex/CON_contactFilterHelper.getBaseClassificationAttributeValuesBasedOnAttribute';
import getContacts from '@salesforce/apex/CON_contactFilterHelper.searchContact';
import getContactsSearchBar from '@salesforce/apex/CON_contactFilterHelper.fetchContacts';

export default class ContactFilter extends LightningElement {
    
    @api recordId;

    @track userId = uId;

    @track items = [];
    @track items2 = [];

    @track currentRecordId;
    @track attributeValue = '';
    @track attributeValueValue = '';

    @track showTable = false;
    @track typeButtonInactive = true;
    @track valueButtonInactive = true;

    @track contactList = [];
    @track recordsToDisplay = [];
    fullDataList = [];
    filterSubSetDataList = [];

    //PAGINATION ATTRIBUTES
    @track page = 1;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 10;
    @track totalRecountCount = 0;
    @track totalPage = 1;
    @track filterActive = false;

    @track columns = [
        {
            label: 'Name',
            fieldName: 'contactUrl',
            type: 'url',
            typeAttributes: {label: {fieldName: 'Name'},
            target: '_self'}
        },
        {
            label: 'Email',
            fieldName: 'Email',
            type: 'email'
        },
        {
            label: 'Phone',
            fieldName: 'Phone'
        },
        {
            label: 'Inactive',
            fieldName: 'IsInactive__c',
            type: 'boolean'
        }
    ]

    @track searchKey;

    @wire(getBaseAttributes, {recordId: '$recordId'})
    wiredGetBaseAttributes ({ error, data }) {

        this.items = [];        

        if (data) {
            for (var i=0; i<data.length; i++) {
                this.items = [...this.items, {value: data[i] , label: data[i]} ];
            }
            this.error = undefined;
        } else if (error) {
            console.log('ERROR ==> ' + error);
            this.error = error;
            this.ClassificationAttributes = undefined;
        }

        getBaseAttributeValues({"recordId": this.currentRecordId})
        .then(result => {

            if (result.length > 0) {
                for (var j=0; j<result.length; j++) {
                    this.items2 = [...this.items2, {value: result[j], label: result[j]} ];
                }
            }

        })

        if (this.recordId != null) {
            this.currentRecordId = this.recordId;
        }

        getContacts({
            "recordId": this.currentRecordId,
            "attributeName" : this.attributeValue,
            "attributeValueName" : this.attributeValueValue
        })
        .then(result => {
            console.log('Getting Contacts');
            let dataset = [];
            dataset = result;

            if (dataset.length > 0) {
                console.log('We found ' + dataset.length + ' contacts.');
                let x = [];

                result.forEach(element => {
                    let elt = {};
                    elt.Id = element.Id;
                    console.log('elt.Id ==> ' + elt.Id);
                    elt.Name = element.Name;
                    console.log('elt.Name ==> ' + elt.Name);
                    elt.Phone = element.Phone;
                    console.log('elt.Phone ==> ' + elt.Phone);
                    elt.Email = element.Email;
                    console.log('elt.Email ==> ' + elt.Email);
                    elt.contactUrl = `/${element.Id}`;
                    console.log('elt.contactUrl ==> ' + elt.contactUrl);
                    elt.IsInactive__c = element.IsInactive__c;
                    console.log('elt.IsInactive__c ==> ' + elt.IsInactive__c);
                    x.push(elt);
                    console.log('-------------------------');
                })

                this.fullDataList = x;

                this.totalRecountCount = this.fullDataList.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                
                this.contactList = this.fullDataList.slice(0,this.pageSize);
                this.endingRecord = this.pageSize;

                this.showTable = true;
            } else {
                console.log('we did not find any Contacts.');
                this.contactList = [];
                this.showTable = false;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error: ' + error);
        })

    }

    // getters to return items mapped with options attribute
    get attributeOptions() {
        return this.items;
    }

    get attributeValueOptions() {
        return this.items2;
    }

    get recordsToDisplayInTable() {
        return this.contactList;
    }

    get disableTypeButton() {
        console.log('this.typeButtonInactive ==> ' + this.typeButtonInactive);
        return this.typeButtonInactive;
    }

    get disableValueButton() {
        console.log('this.valueButtonInactive ==> ' + this.valueButtonInactive);
        return this.valueButtonInactive;
    }

    handleAttributeChange(event) {

        this.attributeValue = event.detail.value;
        this.typeButtonInactive = false;

        console.log('attributeValue ==> ' + this.attributeValue);
        
        getAttributeValuesBasedOnAttribute( {
            "recordId": this.currentRecordId,
            "attributeName" :this.attributeValue
        } )
        .then(result => {
            
            this.items2 = [];
            
            if (result.length > 0) {
                for (var k=0; k<result.length; k++) {
                    this.items2 = [...this.items2, {value: result[k], label: result[k]} ];
                }
            }
        })

        getContacts({
            "recordId": this.currentRecordId,
            "attributeName" : this.attributeValue,
            "attributeValueName" : this.attributeValueValue
        })
        .then(result => {
            console.log('Getting Contacts');
            let dataset = [];
            dataset = result;

            if (dataset.length > 0) {
                console.log('We found ' + dataset.length + ' contacts.');
                let x = [];

                result.forEach(element => {
                    let elt = {};
                    elt.Id = element.Id;
                    console.log('elt.Id ==> ' + elt.Id);
                    elt.Name = element.Name;
                    console.log('elt.Name ==> ' + elt.Name);
                    elt.Phone = element.Phone;
                    console.log('elt.Phone ==> ' + elt.Phone);
                    elt.Email = element.Email;
                    console.log('elt.Email ==> ' + elt.Email);
                    elt.contactUrl = `/${element.Id}`;
                    console.log('elt.contactUrl ==> ' + elt.contactUrl);
                    elt.IsInactive__c = element.IsInactive__c;
                    console.log('elt.IsInactive__c ==> ' + elt.IsInactive__c);
                    x.push(elt);
                    console.log('-------------------------');
                })

                this.fullDataList = x;

                this.totalRecountCount = this.fullDataList.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                
                this.contactList = this.fullDataList.slice(0,this.pageSize);
                this.endingRecord = this.pageSize;

                this.showTable = true;
            } else {
                console.log('we did not find any Contacts.');
                this.contactList = [];
                this.showTable = false;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error: ' + error);
        })
        
    }

    handleAttributeValueChange(event) {

        this.attributeValueValue = event.detail.value;
        this.valueButtonInactive = false;
        console.log('attributeValueValue ==> ' + this.attributeValueValue);

        getContacts({
            "recordId": this.currentRecordId,
            "attributeName" : this.attributeValue,
            "attributeValueName" : this.attributeValueValue
        })
        .then(result => {
            console.log('Getting Contacts');
            let dataset = [];
            dataset = result;

            if (dataset.length > 0) {
                console.log('We found ' + dataset.length + ' contacts.');
                let x = [];

                result.forEach(element => {
                    let elt = {};
                    elt.Id = element.Id;
                    console.log('elt.Id ==> ' + elt.Id);
                    elt.Name = element.Name;
                    console.log('elt.Name ==> ' + elt.Name);
                    elt.Phone = element.Phone;
                    console.log('elt.Phone ==> ' + elt.Phone);
                    elt.Email = element.Email;
                    console.log('elt.Email ==> ' + elt.Email);
                    elt.contactUrl = `/${element.Id}`;
                    console.log('elt.contactUrl ==> ' + elt.contactUrl);
                    elt.IsInactive__c = element.IsInactive__c;
                    console.log('elt.IsInactive__c ==> ' + elt.IsInactive__c);
                    x.push(elt);
                    console.log('-------------------------');
                })

                this.fullDataList = x;

                this.totalRecountCount = this.fullDataList.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                
                this.contactList = this.fullDataList.slice(0,this.pageSize);
                this.endingRecord = this.pageSize;

                this.showTable = true;
            } else {
                console.log('we did not find any Contacts.');
                this.contactList = [];
                this.showTable = false;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error: ' + error);
        })
    }

    handleClearType() {
        this.attributeValue = '';
        this.typeButtonInactive = true;
        this.attributeValueValue = '';
        this.valueButtonInactive = true;
        this.items2 = [];

        getBaseAttributeValues({"recordId": this.currentRecordId})
        .then(result => {
            
            if (result.length > 0) {
                for (var j=0; j<result.length; j++) {
                    this.items2 = [...this.items2, {value: result[j], label: result[j]} ];
                }
            }
        })

        getContacts({
            "recordId": this.currentRecordId,
            "attributeName" : this.attributeValue,
            "attributeValueName" : this.attributeValueValue
        })
        .then(result => {
            console.log('Getting Contacts');
            let dataset = [];
            dataset = result;

            if (dataset.length > 0) {
                console.log('We found ' + dataset.length + ' contacts.');
                let x = [];

                result.forEach(element => {
                    let elt = {};
                    elt.Id = element.Id;
                    console.log('elt.Id ==> ' + elt.Id);
                    elt.Name = element.Name;
                    console.log('elt.Name ==> ' + elt.Name);
                    elt.Phone = element.Phone;
                    console.log('elt.Phone ==> ' + elt.Phone);
                    elt.Email = element.Email;
                    console.log('elt.Email ==> ' + elt.Email);
                    elt.contactUrl = `/${element.Id}`;
                    console.log('elt.contactUrl ==> ' + elt.contactUrl);
                    elt.IsInactive__c = element.IsInactive__c;
                    console.log('elt.IsInactive__c ==> ' + elt.IsInactive__c);
                    x.push(elt);
                    console.log('-------------------------');
                })

                this.fullDataList = x;

                this.totalRecountCount = this.fullDataList.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                
                this.contactList = this.fullDataList.slice(0,this.pageSize);
                this.endingRecord = this.pageSize;

                this.showTable = true;
            } else {
                console.log('we did not find any Contacts.');
                this.contactList = [];
                this.showTable = false;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error: ' + error);
        })

    }

    handleClearValue() {
        this.attributeValueValue = '';
        this.valueButtonInactive = true;

        getContacts({
            "recordId": this.currentRecordId,
            "attributeName" : this.attributeValue,
            "attributeValueName" : this.attributeValueValue
        })
        .then(result => {
            console.log('Getting Contacts');
            let dataset = [];
            dataset = result;

            if (dataset.length > 0) {
                console.log('We found ' + dataset.length + ' contacts.');
                let x = [];

                result.forEach(element => {
                    let elt = {};
                    elt.Id = element.Id;
                    console.log('elt.Id ==> ' + elt.Id);
                    elt.Name = element.Name;
                    console.log('elt.Name ==> ' + elt.Name);
                    elt.Phone = element.Phone;
                    console.log('elt.Phone ==> ' + elt.Phone);
                    elt.Email = element.Email;
                    console.log('elt.Email ==> ' + elt.Email);
                    elt.contactUrl = `/${element.Id}`;
                    console.log('elt.contactUrl ==> ' + elt.contactUrl);
                    elt.IsInactive__c = element.IsInactive__c;
                    console.log('elt.IsInactive__c ==> ' + elt.IsInactive__c);
                    x.push(elt);
                    console.log('-------------------------');
                })

                this.fullDataList = x;

                this.totalRecountCount = this.fullDataList.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                
                this.contactList = this.fullDataList.slice(0,this.pageSize);
                this.endingRecord = this.pageSize;

                this.showTable = true;
            } else {
                console.log('we did not find any Contacts.');
                this.contactList = [];
                this.showTable = false;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error: ' + error);
        })
    }

    handleKeyChange(event) {

        this.page = 1;
        this.searchKey = event.target.value;
        console.log('handleKeyChange searchValue==> ' + this.searchKey);

        getContactsSearchBar({
            "currentRecordId": this.currentRecordId,
            "searchKey": this.searchKey
        })
        .then(result => {
            let dataset = [];
            dataset = result;

            if (dataset.length > 0) {
                console.log('handleKeyChange. We found ' + dataset.length + ' contacts.');
                let x = [];

                result.forEach(element => {
                    let elt = {};
                    elt.Id = element.Id;
                    console.log('elt.Id ==> ' + elt.Id);
                    elt.Name = element.Name;
                    console.log('elt.Name ==> ' + elt.Name);
                    elt.Phone = element.Phone;
                    console.log('elt.Phone ==> ' + elt.Phone);
                    elt.Email = element.Email;
                    console.log('elt.Email ==> ' + elt.Email);
                    elt.contactUrl = `/${element.Id}`;
                    console.log('elt.contactUrl ==> ' + elt.contactUrl);
                    elt.IsInactive__c = element.IsInactive__c;
                    console.log('elt.IsInactive__c ==> ' + elt.IsInactive__c);
                    x.push(elt);
                    console.log('-------------------------');
                })

                this.fullDataList = x;

                this.totalRecountCount = this.fullDataList.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                
                this.contactList = this.fullDataList.slice(0,this.pageSize);
                this.endingRecord = this.pageSize;

                this.showTable = true;
            } else {
                console.log('handleKeyChange. We did not find any Contacts.');
                this.contactList = [];
                this.showTable = false;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('handleKeyChange. Error: ' + JSON.stringify(error));
        })
    }

    //ON CLICK OF PREVIOUS BUTTON
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //DECREASE PAGE NO
            this.displayRecordPerPage(this.page);
        }
    }

    //ON CLICK OF NEXT BUTTON
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //INCREASE PAGE NO
            this.displayRecordPerPage(this.page);            
        }             
    }

    //DISPLAY RECORDS PAGE FOR PAGE
    displayRecordPerPage(page){

        let baseList = [];
        baseList = this.fullDataList;
        console.log("displayRecordPerPage baseList: " + baseList);

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;

        if(this.filterActive == false){
            this.contactList = this.fullDataList.slice(this.startingRecord, this.endingRecord);
            this.startingRecord = this.startingRecord + 1;
        }else{
            this.contactList = this.filterSubSetDataList.slice(this.startingRecord, this.endingRecord);
            this.startingRecord = this.startingRecord + 1;
        }
    }

    //SET DISABLED BUTTON ATTRIBUTE DYNAMICALLY
    get disableButton(){
        return(this.totalPage<2);
    }

}