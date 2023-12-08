import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

import getSalesStatistics from '@salesforce/apex/BL_customBookListHelper.getSalesStatistics';

export default class CustomSalesDataBooklistView extends NavigationMixin(LightningElement) {

    @api recordId;

    @track YearValue;
    @track MonthValue;

    @track items = [];
    @track recordsToDisplay = [];
    @track YearOptions = [];
    @track MonthOptions = [];
    fullDataList = [];

    @track yearSelected = false;
    @track monthSelected = false;

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
            label: 'Product Title',
            fieldName: 'ProductTitle',
        },
        {
            label: 'Value',
            fieldName: 'Value',
            type: 'currency'
        },
        {
            label: 'Quantity',
            fieldName: 'Quantity',
        },
        {
            label: 'Year',
            fieldName: 'Year',
        },
        {
            label: 'CreatedMonth',
            fieldName: 'OrderDate',
        },
        {
            type: 'action', 
            typeAttributes: { 
                rowActions: this.actions, 
                menuAlignment: 'right' 
            } 
        }
    ]

    @wire(getSalesStatistics, { "recordId": '$recordId'})    
    wiredGetSalesStatistics ({ error, data }) {

        let y = [];
        for (let i = new Date().getFullYear(); i >= 2016; i--) {
            y.push({ label: i.toString(), value: i.toString() });
        }
        this.YearOptions = y;

        var options = { month: 'long'};
        let m = [];
        for (let i = 1; i <= 12; i++) {
            let d = new Intl.DateTimeFormat('en-US', options).format(new Date(i+' 25, 1995 23:15:30'))
            m.push({ label: d, value: d});
        }
        this.MonthOptions = m;

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
                    
                    if (element.Product2) {
                        elt.ProductTitle = element.Product2.Name;
                    } else {
                        elt.ProductTitle = '';
                    }
                    
                    if (element.Value__c) {
                        elt.Value = element.Value__c;
                    } else {
                        elt.Value = '-';
                    }
                    
                    if (element.Year__c) {
                        elt.Year = element.Year__c;
                    } else {
                        elt.Year = '-';
                    }
                    
                    if (element.Quantity) {
                        elt.Quantity = element.Quantity;
                    } else {
                        elt.Quantity = '-';
                    }

                    //elt.OrderDate = new Intl.DateTimeFormat('en-US', options).format(new Date(element.OrderDate__c));
                    elt.OrderDate = element.OrderDate__c;

                    x.push(elt);
                    console.log('OrderDate ==> ' + elt.OrderDate);
                    console.log('----------------------');
                })
                this.recordsToDisplay = x;
                this.fullDataList = x;
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

    get YearOptionsSelection() {
        return this.YearOptions;
    }

    createYearOptions() {
        let y = [];
        for (let i = new Date().getFullYear(); i >= 2016; i--) {
            y.push({ label: i.toString(), value: i.toString() });
        }
        this.YearOptions = y;
    }

    createMonthOptions() {
        var options = { month: 'long'};
        let m = [];
        for (let i = 1; i <= 12; i++) {
            let d = new Intl.DateTimeFormat('en-US', options).format(new Date(i+' 25, 1995 23:15:30'))
            m.push({ label: d, value: d});
        }
        this.MonthOptions = m;
    }

    handleYearChange(event) {
        this.yearSelected = true;
        this.YearValue = event.detail.value;
        this.createFilteredList();
    }

    handleMonthChange(event) {
        this.monthSelected = true;
        this.MonthValue = event.detail.value;
        this.createFilteredList();
    }

    createFilteredList() {
        let Baselist = [];
        Baselist = this.fullDataList;
        this.recordsToDisplay = [];

        let x = [];

        for (let i = 0; i < this.fullDataList.length; i ++) {
            let addToList= false;
           
            if (this.yearSelected && this.monthSelected) {
                if (this.fullDataList[i].OrderDate == this.MonthValue && this.fullDataList[i].Year == this.YearValue) {
                    addToList = true;
                }
            } else if (this.yearSelected) {
                if (this.fullDataList[i].Year == this.YearValue) {
                    addToList = true;
                }
            } else if (this.monthSelected) {
                if (this.fullDataList[i].OrderDate == this.MonthValue) {
                    addToList = true;
                }
            }

            if (addToList) {
                x.push(this.fullDataList[i]);
            }
        }
        this.recordsToDisplay = x;
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

}