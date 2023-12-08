import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import MARKETSEGMENT_FIELD from '@salesforce/schema/Product2.MarketSegment__c';

import getListPriceDiscountRecords from '@salesforce/apex/LPD_customListPriceDiscountView_Helper.getListPriceDiscountRecords';

const fields = [MARKETSEGMENT_FIELD];

export default class CustomListPriceDiscountView extends LightningElement {

    @api recordId;

    @track options = [];
    @api selectedValues=[];
    @api label=' '; 
    @track _options= [];
    @track iswindowOpen=false;

    @track itemsToShow = [];
    @track allItems = [];
    @track error;

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
            label: 'Customer Discount Group',
            fieldName: 'CustomerDiscountGroup',
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

    @wire(getRecord, { recordId: '$recordId', fields })
    product;

    @wire(getListPriceDiscountRecords, {
        recordId: '$recordId'
    })
    wiredGetListPriceDiscountRecords({ error, data }) {

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
                if (element.DiscountType__c != 'Market Segment') {
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
                } else if (element.MarketSegment__c === this.product.data.fields.MarketSegment__c.value) {
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
                }
                
            });
            this.allItems = x;
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
    
    get defaultText(){
        if (this.selectedValues.length === 0) {
            return "filter by Customer Discount Group";
        }
        if (this.selectedValues.length === 1) {
            return this.selectedValues[0].label;
        }
        else{
            return this.selectedValues.length+" Options Selected";

        }
    }

    handleClick(event){
        console.log('query selector..'+this.template.querySelector("section"));
        this.iswindowOpen=true;
        this.template.querySelector("section").classList.add("slds-is-open");
    }

    handleMouseOut(event){
       if(this.iswindowOpen){
            return;
       }
       this.template.querySelector("section").classList.remove("slds-is-open");
    }

    handleMouseLeave(event){
        this.iswindowOpen=false;
        this.template.querySelector("section").classList.remove("slds-is-open");

    }

    handlemouseOver(event){
        this.iswindowOpen=true;
    }

    handleSelectedClick(event){

        var value;
        var selected;
        event.preventDefault();
        event.stopPropagation();
    
        const data = event.detail;
    
        value = data.value;
        selected = data.selected;
    
        //shift key ADDS to the list (unless clicking on a previously selected item)
        //also, shift key does not close the dropdown.
        if (data.shift) {
            this._options.forEach(function(option) {
                if (option.value === value) {
                    option.selected = selected === true ? false : true;
                }
            });
        }
        else {
            this._options.forEach(function(option) {
                if (option.value === value) {
                    option.selected = selected === "true" ? false : true;
                } else {
                    option.selected = false;
                }
            });
            // this.closeDropdown();
        }
        this.selectedValues = this.getOptionsArray();
        console.log('this.selectedValues ==> ' + JSON.stringify(this.selectedValues));
        this.createDevisions(this.allItems);
    }

    getOptionsArray(){
        var pills = [];
        this._options.forEach(function(element) {
            var interator = 0;
            if (element.selected) {
                pills.push({label:element.label, name:element.value, key: interator++});
            }
        });
        return pills;
    }

}