import { LightningElement, track, wire, api } from 'lwc';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from "lightning/navigation";

import ASSET_OBJECT from '@salesforce/schema/Asset';
import SCHOOLYEAR_FIELD from '@salesforce/schema/Asset.SchoolYear__c';

import getAssets from '@salesforce/apex/BL_customBookListHelper.getBookLists';

export default class CustomBookListView extends NavigationMixin(LightningElement) {

    @api recordId;

    @track schoolYearValue;
    @track currentRecordId;

    @track items = [];
    @track recordsToDisplay = [];
    fullDataList = [];
    filterSubSetDataList = [];

    @track year1Val = false;
    @track year2Val = false;
    @track year3Val = false;
    @track year4Val = false;
    @track year5Val = false;
    @track year6Val = false;

    //PAGINATION ATTRIBUTES
    @track page = 1;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 15;
    @track totalRecountCount = 0;
    @track totalPage = 1;
    @track filterActive = false;

    @track actions = [
        { label: 'Edit', name: 'Edit' },
        { label: 'Clone', name: 'Clone' }
    ]

    @track columns = [
        {
            label: 'Name',
            fieldName: 'Url',
            type: 'url',
            typeAttributes: {label: {fieldName: 'Name'},
            target: '_self'}
        },
        {
            label: 'Schoolyear',
            fieldName: 'SchoolYear',
        },
        {
            label: 'Booklist',
            fieldName: 'booklistUrl',
            type: 'url',
            typeAttributes: {label: {fieldName: 'booklistName'},
            target: '_self'}
        },
        {
            label: 'SubType',
            fieldName: 'subType',
        },
        {
            label: 'Year 1',
            fieldName: '',
            cellAttributes: {
                iconName: {
                    fieldName: 'year1'
                }
            },
            initialWidth: 60,
            hideDefaultActions: true
        },
        {
            label: 'Year 2',
            fieldName: '',
            cellAttributes: {
                iconName: {
                    fieldName: 'year2'
                }
            },
            initialWidth: 60,
            hideDefaultActions: true
        },
        {
            label: 'Year 3',
            fieldName: '',
            cellAttributes: {
                iconName: {
                    fieldName: 'year3'
                }
            },
            initialWidth: 60,
            hideDefaultActions: true
        },
        {
            label: 'Year 4',
            fieldName: '',
            cellAttributes: {
                iconName: {
                    fieldName: 'year4'
                }
            },
            initialWidth: 60,
            hideDefaultActions: true
        },
        {
            label: 'Year 5',
            fieldName: '',
            cellAttributes: {
                iconName: {
                    fieldName: 'year5'
                }
            },
            initialWidth: 60,
            hideDefaultActions: true
        },
        {
            label: 'Year 6',
            fieldName: '',
            cellAttributes: {
                iconName: {
                    fieldName: 'year6'
                }
            },
            initialWidth: 60,
            hideDefaultActions: true
        },
        {
            type: 'action', 
            typeAttributes: { 
                rowActions: this.actions, 
                menuAlignment: 'right' 
            } 
        }
    ]

    @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    assetMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$assetMetadata.data.defaultRecordTypeId',
            fieldApiName: SCHOOLYEAR_FIELD
        })
    schoolYearPicklist;

    @wire(getAssets, { "recordId": '$recordId'})    
    wiredGetAssets ({ error, data }) {

        this.currentRecordId = this.recordId;

        if (data) {
            if (data.length > 0) {
                let x = [];
    
                data.forEach(element => {
                    let elt = {};
                    elt.Id = element.Id;
                    elt.Url = `/${element.Id}`;

                    if (element.Name) {
                        elt.Name = element.Name;
                    } else {
                        elt.Name = '-';
                    }
                    
                    if (element.SchoolYear__c) {
                        elt.SchoolYear = element.SchoolYear__c;
                    } else {
                        elt.SchoolYear = '-';
                    }
                    
                    if (element.Booklist__c) {
                        elt.booklistUrl = `/${element.Booklist__c}`;
                        elt.booklistName = element.Booklist__r.Name;
                    } else {
                        elt.booklistUrl = '';
                        elt.booklistName = '-';
                    }

                    if (element.Subtype__c) {
                        elt.subType = element.Subtype__c;
                    } else {
                        elt.subType = '-';
                    }
                    
                    if (element.Year1__c) {
                        elt.year1 = 'utility:check';
                    } else {
                        elt.year1 = null;
                    }
                    if (element.Year2__c) {
                        elt.year2 = 'utility:check';
                    } else {
                        elt.year2 = null;
                    }
                    if (element.Year3__c) {
                        elt.year3 = 'utility:check';
                    } else {
                        elt.year3 = null;
                    }
                    if (element.Year4__c) {
                        elt.year4 = 'utility:check';
                    } else {
                        elt.year4 = null;
                    }
                    if (element.Year5__c) {
                        elt.year5 = 'utility:check';
                    } else {
                        elt.year5 = null;
                    }
                    if (element.Year6__c) {
                        elt.year6 = 'utility:check';
                    } else {
                        elt.year6 = null;
                    }
                    x.push(elt);
                })
                this.recordsToDisplay = x;
                this.fullDataList = x;

                this.totalRecountCount = this.recordsToDisplay.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                
                this.recordsToDisplay = this.fullDataList.slice(0,this.pageSize);
                this.endingRecord = this.pageSize;
            }
        } else if (error) {
            console.log('ERROR: ' + error);
        } else {
            console.log('we have found no data');
        }
    }

    get recordsToDisplayInTable() {
        return this.recordsToDisplay;
    }

    handleYearOneBox() {
        this.year1Val = !this.year1Val;
        this.createFilteredList();
    }

    handleYearTwoBox() {
        this.year2Val = !this.year2Val;
        this.createFilteredList();
    }

    handleYearThreeBox() {
        this.year3Val = !this.year3Val;
        this.createFilteredList();
    }

    handleYearFourBox() {
        this.year4Val = !this.year4Val;
        this.createFilteredList();
    }

    handleYearFiveBox() {
        this.year5Val = !this.year5Val;
        this.createFilteredList();
    }

    handleYearSixBox() {
        this.year6Val = !this.year6Val;
        this.createFilteredList();
    }

    handleSchoolYearChange(event) {
        this.schoolYearValue = event.detail.value;
        this.createFilteredList();
    }

    createFilteredList() {
        let Baselist = [];
        Baselist = this.fullDataList;
        this.recordsToDisplay = [];

        let x = [];

        for (let i = 0; i < this.fullDataList.length; i ++) {
            let schoolYearNotEmpty = false;
            let schoolYearMatch = false;
            let addToList = false;

            if (this.schoolYearValue != null) {
                schoolYearNotEmpty = true;
                if (this.fullDataList[i].SchoolYear === this.schoolYearValue) {
                    schoolYearMatch = true;
                    addToList = true;
                }

                if (schoolYearMatch) {
                    if (this.year1Val === true && this.fullDataList[i].year1 === null) {
                        addToList = false;
                    } 
                    if (this.year2Val === true && this.fullDataList[i].year2 === null) {
                        addToList = false;
                    }
                    if (this.year3Val === true && this.fullDataList[i].year3 === null) {
                        addToList = false;
                    }
                    if (this.year4Val === true && this.fullDataList[i].year4 === null) {
                        addToList = false;
                    }
                    if (this.year5Val === true && this.fullDataList[i].year5 === null) {
                        addToList = false;
                    }
                    if (this.year6Val === true && this.fullDataList[i].year6 === null) {
                        addToList = false;
                    }
                } 
            } else {
                if ((this.year1Val === true && this.fullDataList[i].year1 === 'utility:check') || (this.year2Val === true && this.fullDataList[i].year2 === 'utility:check') || (this.year3Val === true && this.fullDataList[i].year3 === 'utility:check') || (this.year4Val === true && this.fullDataList[i].year4 === 'utility:check') || (this.year5Val === true && this.fullDataList[i].year5 === 'utility:check') || (this.year6Val === true && this.fullDataList[i].year6 === 'utility:check')) {
                    addToList = true;
                }
            }

            if (addToList) {
                x.push(this.fullDataList[i]);
            }
        }

        this.recordsToDisplay = x;
        this.filterSubSetDataList = x;

        this.totalRecountCount = x.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
        
        this.recordsToDisplay = this.filterSubSetDataList.slice(0,this.pageSize);
        this.endingRecord = this.totalPage;
        this.filterActive = true;

        if ((this.schoolYearValue === null || this.schoolYearValue === undefined) && 
            (this.year1Val === null || this.year1Val === false) && 
            (this.year2Val === null || this.year2Val === false) && 
            (this.year3Val === null || this.year3Val === false) && 
            (this.year4Val === null || this.year4Val === false) && 
            (this.year5Val === null || this.year5Val === false) && 
            (this.year6Val === null || this.year6Val === false)) {
                this.recordsToDisplay = this.fullDataList;

                this.totalRecountCount = this.recordsToDisplay.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

                this.recordsToDisplay = this.fullDataList.slice(0,this.pageSize);
                this.filterActive = false;
                this.startingRecord = 1;
                this.page = 1;
                this.endingRecord = this.pageSize;
        }
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'Edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'edit',
                    },
                });
                break;
            case 'Clone':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'clone',
                    },
                });
                break;
        }
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
            baseList = this.filterSubSetDataList;
            console.log("displayRecordPerPage baseList: " + baseList);

            this.startingRecord = ((page -1) * this.pageSize) ;
            this.endingRecord = (this.pageSize * page);
    
            this.endingRecord = (this.endingRecord > this.totalRecountCount) ? this.totalRecountCount : this.endingRecord;

            if(this.filterActive == false){
                this.recordsToDisplay = this.fullDataList.slice(this.startingRecord, this.endingRecord);
                this.startingRecord = this.startingRecord + 1;
            }else{
                this.recordsToDisplay = this.filterSubSetDataList.slice(this.startingRecord, this.endingRecord);
                this.startingRecord = this.startingRecord + 1;
            }
        }

        //SET DISABLED BUTTON ATTRIBUTE DYNAMICALLY
        get disableButton(){
            return(this.totalPage<2);
        }

}