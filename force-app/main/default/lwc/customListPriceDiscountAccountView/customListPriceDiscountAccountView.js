import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

//import MARKETSEGMENT_FIELD from '@salesforce/schema/Product2.MarketSegment__c';

import getListPriceDiscountRecords from '@salesforce/apex/LPD_customListPriceDiscountView_Helper.getListPriceDiscountRecordsForAccount';

//const fields = [MARKETSEGMENT_FIELD];

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ListPriceDiscount_OBJECT from '@salesforce/schema/ListPriceDiscount__c';
import ProductDiscountGroup_FIELD from '@salesforce/schema/ListPriceDiscount__c.ProductDiscountGroup__c';
import OrderLineTypeGroup_FIELD from '@salesforce/schema/ListPriceDiscount__c.OrderLineType__c';
import MarketSegmentGroup_FIELD from '@salesforce/schema/ListPriceDiscount__c.MarketSegment__c';

export default class CustomListPriceDiscountAccountView extends LightningElement {

    // getting the default record type id, if you dont' then it will get master
    @wire(getObjectInfo, { objectApiName: ListPriceDiscount_OBJECT })
    listPriceDiscountMetadata;

    // now retriving the Product Discount Group picklist values of Opportunity
    @wire(getPicklistValues,
        {
            recordTypeId: '$listPriceDiscountMetadata.data.defaultRecordTypeId', 
            fieldApiName: ProductDiscountGroup_FIELD
        }
    )
    ProductDiscountGroupPicklist;
    // display the selected picklist value
    
    // now retriving the Order LineType picklist values of Opportunity
    @wire(getPicklistValues,
        {
            recordTypeId: '$listPriceDiscountMetadata.data.defaultRecordTypeId', 
            fieldApiName: OrderLineTypeGroup_FIELD
        }
    )
    OrderLineTypePicklist;
    // display the selected picklist value

    // now retriving the Market Segment picklist values of Opportunity
    @wire(getPicklistValues,
        {
            recordTypeId: '$listPriceDiscountMetadata.data.defaultRecordTypeId', 
            fieldApiName: MarketSegmentGroup_FIELD
        }
    )
    MarketSegmentPicklist;
    // display the selected picklist value

    ProductDiscountGroupValue = '';
    OrderLineTypeValue = '';
    MarketSegmentValue = '';
    //selectedLabel = '';

    @api recordId;
    @api objectApiName;

    @track options = [];
    @api selectedValues=[];
    @api label=' '; 
    @track _options= [];
    @track iswindowOpen=false;

    @track itemsToShow = [];
    @track allItems = [];
    @track fullDataList = [];
    @track error;
    @track disableClearButton = true;
    @track disableProductDiscountGroupPicklist = false;
    @track disableOrderLineTypePicklist = false;
    @track disableMarketSegmentPicklist = false;

    @track columns = [
        {
            label: 'Name', 
            fieldName: 'Url',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                }
            },
            hideDefaultActions: "true",
            sortable: true
        },
        {
            label: 'Product Discount Group',
            fieldName: 'ProductDiscountGroup',
            hideDefaultActions: "true",
            sortable: true
        },
        {
            label: 'Order LineType',
            fieldName: 'OrderLineType',
            hideDefaultActions: "true",
            sortable: true
        },
        {
            label: 'Market Segment',
            fieldName: 'MarketSegment',
            hideDefaultActions: "true",
            sortable: true
        },
        {
            label: 'Start quantity',
            fieldName: 'StartQuantity',
            hideDefaultActions: "true",
            sortable: true,
            cellAttributes: {
                alignment: 'right' 
            }
        },
        {
            label: 'Rate',
            fieldName: 'Rate',
            type: 'percent',
            hideDefaultActions: "true",
            sortable: true,
            cellAttributes: {
                alignment: 'right' 
            }
        }

    ]

    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';

    /*@wire(getRecord, { recordId: '$recordId', fields })
    product;*/

    @wire(getListPriceDiscountRecords, {
        recordId: '$recordId'
    })
    wiredGetListPriceDiscountRecords({ error, data }) {
        console.log('objectApiName: ' + this.objectApiName);
        if (data) {
            let x = [];
            let z = [];
            let cdg = '';

            data.forEach(element => {
                if (cdg != element.CustomerDiscountGroup__c) {
                    cdg = element.CustomerDiscountGroup__c;
                    let option = {};
                    option.label = cdg;
                    option.value = cdg;
                    option.selected = false;
                    z.push(option);
                }
                let elt = {};
                elt.Id = element.Id;
                elt.Name = element.Name;
                elt.Url = `/${element.Id}`;
                elt.StartQuantity = element.StartQuantity__c;
                elt.Rate = element.Rate__c/100;
                elt.ProductDiscountGroup = element.ProductDiscountGroup__c;
                elt.OrderLineType = element.OrderLineType__c;
                elt.MarketSegment = element.MarketSegment__c;
                x.push(elt);
                /*if (element.DiscountType__c != 'Market Segment') {
                    let elt = {};
                    elt.Id = element.Id;
                    elt.Name = element.Name;
                    elt.Url = `/${element.Id}`;
                    elt.StartQuantity = element.StartQuantity__c;
                    elt.Rate = element.Rate__c/100;
                    elt.CustomerDiscountGroup = element.CustomerDiscountGroup__c;
                    elt.OrderLineType = element.OrderLineType__c;
                    elt.MarketSegment = element.MarketSegment__c;
                    x.push(elt);
                }*/ /*else if (element.MarketSegment__c === this.product.data.fields.MarketSegment__c.value) {
                    let elt = {};
                    elt.Id = element.Id;
                    elt.Name = element.Name;
                    elt.Url = `/${element.Id}`;
                    elt.StartQuantity = element.StartQuantity__c;
                    elt.Rate = element.Rate__c/100;
                    elt.CustomerDiscountGroup = element.CustomerDiscountGroup__c;
                    elt.OrderLineType = element.OrderLineType__c;
                    elt.MarketSegment = element.MarketSegment__c;
                    x.push(elt); 
                }*/
                
            });
            this.allItems = x;
            this.fullDataList = x;
            this._options = z;
            console.log('this.selectedValues.length ==> ' + this.selectedValues.length);
            console.log('OPTIONS ====> ' + JSON.stringify(this._options));
            this.createDevisions(this.allItems);
        }

        if (error) {
            this.error = error;
            console.log('ERROR: ' + error);
        }
    }

    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.allItems];

        cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
        this.allItems = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;

    }

    sortBy( field, reverse, primer ) {

        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            return reverse * ( ( a > b ) - ( b > a ) );
        };

    }



// OLD ##################################
    createDevisions(data) {
        
        if (data) {
            let cdg = '';
            let x = [];
            let y = [];
            var first_iteration = true;

            data.forEach(element => {
                let elem = element;
                if (first_iteration) {
                    if (this.selectedValues.length == 0 || this.selectedValues.some(e => e.label === elem.CustomerDiscountGroup) ) {
                        cdg = elem.CustomerDiscountGroup;
                    }
                }
                if (this.selectedValues.length == 0 || this.selectedValues.some(e => e.label === elem.CustomerDiscountGroup) ) {
                    if (cdg == elem.CustomerDiscountGroup && element !== data[data.length]) {
                        y.push(elem);
                    } else {
                        if (cdg != '') {
                            let elt = {};
                            elt.cdg = cdg;
                            elt.items = y;
                            x.push(elt);
                        }
                        cdg = elem.CustomerDiscountGroup;
                        y = [];
                        y.push(elem);
                    }
                }
                first_iteration = false;
            })
            if (this.selectedValues.length > 0) {
                let elt = {};
                        elt.cdg = cdg;
                        elt.items = y;
                        x.push(elt);
            }
            console.log('x ==> ' + JSON.stringify(x));
            this.itemsToShow = x;
        }

    }

    handleChange(event){
        this.disableClearButton = false;
        //this.allItems = [];
        var source = event.currentTarget.dataset.fieldvalue;
        //console.log('*source: ' + source);
        //console.log('*value: ' + event.detail.value);
        let filteredList = [];

        if(source == 'productDiscountGroupId'){
            this.ProductDiscountGroupValue = event.detail.value;
            this.disableOrderLineTypePicklist = true;
            this.disableMarketSegmentPicklist = true;
        }
        if(source == 'orderLineTypeId'){
            this.OrderLineTypeValue = event.detail.value;
            this.disableProductDiscountGroupPicklist = true;
            this.disableMarketSegmentPicklist = true;
        }
        if(source == 'marketSegmentId'){
            this.MarketSegmentValue = event.detail.value;
            this.disableProductDiscountGroupPicklist = true;
            this.disableOrderLineTypePicklist = true;
        }
        
        console.log('*ProductDiscountGroupValue: ' + this.ProductDiscountGroupValue);
        console.log('*OrderLineTypeValue: ' + this.OrderLineTypeValue);
        console.log('*MarketSegmentValue: ' + this.MarketSegmentValue);

        //console.log('*allItems lenght before: ' + this.allItems.length);
        for(let i = 0; i < this.fullDataList.length; i++){
            let addToList = false;
            //console.log('**ProductDiscountGroupValue 1: ' + this.ProductDiscountGroupValue);
            //console.log('**ProductDiscountGroupValue 2: ' + this.allItems[i].ProductDiscountGroup);
            if(this.fullDataList[i].ProductDiscountGroup == this.ProductDiscountGroupValue){
                addToList = true;
            }
            if(this.fullDataList[i].OrderLineType == this.OrderLineTypeValue){
                addToList = true;
            }
            if(this.fullDataList[i].MarketSegment == this.MarketSegmentValue){
                addToList = true;
            }
            //console.log('**addToList: ' + addToList);
            if(addToList){
                //console.log('**Adding Item To List**');
                filteredList.push(this.fullDataList[i]);
            }
        }
        //console.log('*filteredList lenght: ' + filteredList.length);
        this.allItems = filteredList;
        //console.log('*allItems lenght after: ' + this.allItems.length);
    }

    handleClear(){
        this.ProductDiscountGroupValue = '';
        this.OrderLineTypeValue = '';
        this.MarketSegmentValue = '';
        this.disableClearButton = true;
        this.disableProductDiscountGroupPicklist = false;
        this.disableOrderLineTypePicklist = false;
        this.disableMarketSegmentPicklist = false;

        this.allItems = this.fullDataList;
    }

    get disableClearButton(){
        return this.disableClearButton;
    }

    get disableProductDiscountGroupPicklist(){
        return this.disableProductDiscountGroupPicklist;
    }

    get disableOrderLineTypePicklist(){
        return this.disableOrderLineTypePicklist;
    }

    get disableMarketSegmentPicklist(){
        return this.disableMarketSegmentPicklist;
    }

}