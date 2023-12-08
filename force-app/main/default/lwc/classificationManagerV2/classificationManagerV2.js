import { LightningElement, wire, track, api } from 'lwc';

import getClassificationAttributes from '@salesforce/apex/CM_ClassificationManagerHelper.getClassificationAttributes';
import getClassificationAttributeValueByAttributeId from '@salesforce/apex/CM_ClassificationManagerHelper.getClassificationAttributeValueByAttributeId';
import getClassificationAttributeValueByParentId from '@salesforce/apex/CM_ClassificationManagerHelper.getClassificationAttributeValueByParentId';
import createClassificationDetail from '@salesforce/apex/CM_ClassificationManagerHelper.createClassificationData';

export default class ClassificationManager extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api recordType;
    @track currentRecordId;

    @track items = [];
    @track items2 = [];
    @track items3 = [];
    @track items4 = [];
    @track items5 = [];
    
    @track value = '';
    @track value2 = '';
    @track value3 = '';
    @track value4 = '';
    @track value5 = '';
    @track yearValue = '';
    @track gradeValue = '';
    
    @track chosenValue = '';
    @track chosenValue2 = '';
    @track chosenValue3 = '';
    @track chosenValue4 = '';
    @track chosenValue5 = '';
    @track chosenYearValue = '';
    @track chosenGradeValue = '';
    @track chosenStudentNumberValue = '';

    @track Value2Div = false;
    @track Value3Div = false;
    @track Value4Div = false;
    @track Value5Div = false;
    @track studentNrInputVis = false;
    @track yearInputVis = false;
    @track resultContainer = true;
    @track results = true;
    @track loading = false;
    @track btnCreateClassificationVis = true;
    @track chosenYearBoolean = true;
    @track chosenGradeBoolean = true;
    @track chosenStudentNumBoolean = true;
    
    @track titleClass = 'modalHeaderTextGood';
    @track endResult = '';
    @track error;
    
    @wire(getClassificationAttributes, { "recordId": '$recordId' })
    wiredClassificationAttributes({ error, data }) {


        this.resultContainer = false;
        this.results = false;
        this.currentRecordId = this.recordId;

        if (data) {
            for (var i=0; i<data.length; i++) {
                this.items = [...this.items, {value: data[i].Id , label: data[i].Name} ];
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.ClassificationAttributes = undefined;
        }
    }

    // getters to return items mapped with options attribute
    get classificationOptions() {
        return this.items;
    }

    get selectedValue () {
        return this.chosenValue;
    }

    handleAttributeChange(event) {
        // get string of the "value" attribute on the delected option
        const selectedOption = event.detail.value;
        console.log('selected Option 1: ' + selectedOption);
        this.chosenValue = selectedOption;

        getClassificationAttributeValueByAttributeId({
            "attributeId": this.chosenValue,
            "recordId": this.currentRecordId
        })
        .then(result => {
            this.value = '';
            this.items2 = [];
            this.chosenValue2 = '';
            this.items3 =[];
            this.chosenValue3 = '';
            this.items4 =[];
            this.chosenValue4 = '';
            this.Value3Div = false;
            this.Value4Div = false;
            this.yearInputVis = false;
            this.studentNrInputVis = false;

            if (result.length > 0) {    
                this.Value2Div = true;

                for (var j=0; j<result.length; j++) {
                    this.items2 = [...this.items2, {value: result[j].Id, label: result[j].Name} ];
                }
                document.getElementById('+"ClassificationAttributeValue"+').size = '2';
            } else {
                this.Value2Div = false;
                if (this.objectApiName == "Contact") {
                    this.yearInputVis = true;
                } else {
                    this.studentNrInputVis = true;
                    console.log("You are on an Account object");
                }
            }
        })
        .catch(error => {
            this.error = error;
            console.log("Error: " + error);
        })
    }

    get classificationAttributeValueOptions() {
        return this.items2;
    }

    // get SetectedValue2 () {
    //     return this.chosenValue2;
    // }

    handleValueChange(event) {
        const selectedOption = event.detail.value;
        console.log('Selected Option 2: ' + selectedOption);
        this.chosenValue2 = selectedOption;

        getClassificationAttributeValueByParentId({
            "parentId" : this.chosenValue2,
            "recordId": this.currentRecordId
        })
        .then(result => {
            
            this.items3 =[];
            this.chosenValue3 = '';
            this.items4 =[];
            this.chosenValue4 = '';
            this.Value4Div = false;
            this.yearInputVis = false;
            this.studentNrInputVis = false;

            if (result.length > 0) {
                this.Value3Div = true;
                for (var k=0; k<result.length; k++) {
                    this.items3 = [...this.items3, {value: result[k].Id, label: result[k].Name} ];
                }
            } else {
                this.Value3Div = false;
                if (this.objectApiName == "Contact") {
                    this.yearInputVis = true;
                } else {
                    this.studentNrInputVis = true;
                    console.log("You are on an Account object");
                }
            }
        })
        .catch(error => {
            this.error = error;
        })
    }

    get classificationAttributeValue2Options() {
        return this.items3;
    }

    get SetectedValue3 () {
        return this.chosenValue2;
    }

    handleValue2Change(event) {
        const selectedOption = event.detail.value;
        console.log('Selected Option 3: ' + selectedOption);
        this.chosenValue3 = selectedOption;

        getClassificationAttributeValueByParentId({
            "parentId" : this.chosenValue3,
            "recordId": this.currentRecordId
        })
        .then(result => {

            this.items4 =[];
            this.chosenValue4 = '';
            this.yearInputVis = false;
            this.studentNrInputVis = false;

            if (result.length > 0) {
                this.Value4Div = true;
                for (var l=0; l<result.length; l++) {
                    this.items4 = [...this.items4, {value: result[l].Id, label: result[l].Name} ];
                }
            } else {
                this.Value4Div = false;
                if (this.objectApiName == "Contact") {
                    this.yearInputVis = true;
                } else {
                    this.studentNrInputVis = true;
                    console.log("You are on an Account object");
                }
            }
        })
        .catch(error => {
            this.error = error;
        })
    }

    get classificationAttributeValue3Options() {
        return this.items4;
    }

    get SetectedValue4 () {
        return this.chosenValue4;
    }

    handleValue3Change(event) {
        const selectedOption = event.detail.value;
        console.log('Selected Option4: ' + selectedOption);
        this.chosenValue4 = selectedOption;

        getClassificationAttributeValueByParentId({
            "parentId" : this.chosenValue4,
            "recordId": this.currentRecordId
        })
        .then(result => {

            this.items5 =[];
            this.chosenValue5 = '';
            this.yearInputVis = false;
            this.studentNrInputVis = false;

            if (result.length > 0) {
                this.Value5Div = true;
                for (var l=0; l<result.length; l++) {
                    this.items5 = [...this.items5, {value: result[l].Id, label: result[l].Name} ];
                }
            } else {
                this.Value5Div = false;
                if (this.objectApiName == "Contact") {
                    this.yearInputVis = true;
                } else {
                    this.studentNrInputVis = true;
                    console.log("You are on an Account object");
                }
            }
        })
        .catch(error => {
            this.error = error;
        })
    }

    handleValue4Change(event) {
        const selectedOption = event.detail.value;
        console.log('Selected Option5: ' + selectedOption);
        this.chosenValue5 = selectedOption;
    }

    get classificationAttributeValue4Options() {
        return this.items5;
    }

    get SetectedValue5 () {
        return this.chosenValue5;
    }

    handleYearChange(event) {
        var x = event.target.value;
        this.chosenYearValue = x;

        this.chosenYearBoolean = this.isNumber(this.chosenYearValue);
        this.showBtnCreateClassificationContact();
    }

    handleGradeChange(event) {
        var y = event.target.value;
        this.chosenGradeValue = y;

        this.chosenGradeBoolean = this.isNumber(this.chosenGradeValue);
        this.showBtnCreateClassificationContact();
    }

    handleStudentNumberChange(event) {
        var z = event.target.value;
        this.chosenStudentNumberValue = z;

        this.chosenStudentNumBoolean = this.isNumber(this.chosenStudentNumberValue);
        this.showBtnCreateClassificationAccount();
    }

    isNumber(num) { 
        return /^-?[\d.]+(?:e-?\d+)?$/.test(num);
    }

    showBtnCreateClassificationContact(){
        if(this.chosenYearBoolean & this.chosenGradeBoolean) {
            console.log("Validation passed");
            this.btnCreateClassificationVis = true;
        } else {
            console.log("Validation error, Year and/or Grade must be numeric");
            this.btnCreateClassificationVis = false;
        }
    }

    showBtnCreateClassificationAccount(){
        if(this.chosenStudentNumBoolean) {
            console.log("Validation passed");
            this.btnCreateClassificationVis = true;
        } else {
            console.log("Validation error, Student Number must be numeric");
            this.btnCreateClassificationVis = false;
        }
    }

    createCustomDetail() {

        this.loading = true;
        this.resultContainer = true;

        console.log(
            "creating ClassificationData:\n"+
            this.objectApiName + " ID: " + this.currentRecordId + "\n" +
            "AttributeId: " + this.chosenValue + "\n" +
            "AttributeValueId: " + this.chosenValue2 + "\n" +
            "AttributeSubValueId: " + this.chosenValue3 + "\n" +
            "AttributeSubValue2Id: " + this.chosenValue4 + "\n" +
            "AttributeSubValue3Id: " + this.chosenValue5 + "\n" +
            "Year: " + this.chosenYearValue + "\n" +
            "Grade: " + this.chosenGradeValue + "\n" +
            "StudentNumbers: " + this.chosenStudentNumberValue
        );

        createClassificationDetail({
            "recordId": this.currentRecordId,
            "AttributeId": this.chosenValue,
            "AttributeValueId": this.chosenValue2,
            "AttributeValue2Id": this.chosenValue3,
            "AttributeValue3Id": this.chosenValue4,
            "AttributeValue4Id": this.chosenValue5,
            "yearValue": this.chosenYearValue,
            "gradeValue": this.chosenGradeValue,
            "studentNumberValue" : this.chosenStudentNumberValue
        })
        .then(result => {
            console.log("classificationManager.js result: " + result);
            if (result != "Succesfully created the Classification Data Record.") {
                this.titleClass = "modalHeaderTextBad";
            }
            this.endResult = result;
            this.loading = false;
            this.resultContainer = true;
            this.results = true;
            window.stop();
        })
        .catch(error => {
            this.error = error;
        })
    }

    get insertResult () {
        return this.endResult;
    }

    get finalTitle () {
        var title;
        if (this.endResult == "Succesfully created the Classification Data Record.") {
            title = "SUCCESS";
        } else {
            title = "WARNING";
        }
        return title;
    }

    done() {
        this.template.querySelectorAll('lightning-combobox').forEach(each => {each.value = undefined}); //reset all combobox values
        this.results = false;
        this.loading = false;
        this.resultContainer = false;
        this.titleClass = "modalHeaderTextGood";
        this.chosenValue = '';
        this.items2 = [];
        this.chosenValue2 = '';
        this.items3 =[];
        this.chosenValue3 = '';
        this.items4 =[];
        this.chosenValue4 = '';
        this.Value2Div = false;
        this.Value3Div = false;
        this.Value4Div = false;
        this.yearInputVis = false;
        this.studentNrInputVis = false;
        this.updateRecordView();
    }

    //refresh standard components view
    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 1000); 
     }

}