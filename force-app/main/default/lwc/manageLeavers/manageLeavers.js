import { LightningElement, track, wire } from 'lwc';
import Id from '@salesforce/user/Id';

import getZendeskUser from '@salesforce/apex/ML_manageLeaversController.getZendeskUser';
import suspendZendeskUser from '@salesforce/apex/ML_manageLeaversController.suspendZendeskdUser'
import getSwellUser from '@salesforce/apex/ML_manageLeaversController.getSwellUser';
import deleteSwellUser from '@salesforce/apex/ML_manageLeaversController.deleteSwellUser';

import getAccounts from '@salesforce/apex/ML_manageLeaversController.checkAccounts';
import getContacts from '@salesforce/apex/ML_manageLeaversController.checkContacts';
import getOrders from '@salesforce/apex/ML_manageLeaversController.checkOrders';
import getOpportunities from '@salesforce/apex/ML_manageLeaversController.checkOpportunities';
import getCases from '@salesforce/apex/ML_manageLeaversController.checkCases';
import getCampaigns from '@salesforce/apex/ML_manageLeaversController.checkCampaigns';
import getDashboards from '@salesforce/apex/ML_manageLeaversController.checkDashboards';
import getCustomMetadataTypes from '@salesforce/apex/ML_manageLeaversController.checkCustomMetadataTypes';

import deactivateUser from '@salesforce/apex/ML_manageLeaversController.deactivateUser';
import updateAccountOwner from '@salesforce/apex/ML_manageLeaversController.updateAccountOwner';
import updateContactOwner from '@salesforce/apex/ML_manageLeaversController.updateContactOwner';
import updateOrderOwner from '@salesforce/apex/ML_manageLeaversController.updateOrderOwner';
import updateOpportunityOwner from '@salesforce/apex/ML_manageLeaversController.updateOpportunityOwner';
import updateCaseOwner from '@salesforce/apex/ML_manageLeaversController.updateCaseOwner';
import updateCampaignOwner from '@salesforce/apex/ML_manageLeaversController.updateCampaignOwner';

export default class ManageLeavers extends LightningElement {

    @track userId = Id;
    @track users;
    @track error;
    @track zendeskCheckboxValue = true;
    @track swellCheckboxValue = true;
    @track recordsFoundTxt = 'Records';
    @track changeOwner = false;
    @track changeDashboardOwner = false;
    @track finished = false;

    @track showDashboardResults = false;
    @track dashboardList = [];

    @track showApexResults = false;
    @track apexList = [];

    @track accountsFound;
    @track contactsFound;
    @track ordersFound;
    @track opportunitiesFound;
    @track casesFound;
    @track campaignsFound;
    @track dashboardsFound;
    @track apexFound;
    @track selectedUserName = 'leaver';

    accountList;
    contactList;
    orderList;
    opportunityList;
    caseList;
    campaignList;
    dashboardList;

    selectedUser;
    zendeskUserId;
    swellUserId;
    changeRecordSelectedUser;
    changeDashboardSelectedUser;

    errorMessage = 'Errors:';

    loadingValue = 0;

    zendeskSearchDone = false;
    swellSearchDone = false;
    zendeskUserFound = false;
    swellUserFound = false;
    displayError = false;

    handleValueSelectedOnUser(event) {
        this.loadingValue = 1;
        let hostname = window.location.hostname;
        console.log('hostname => ' + hostname);
        
        this.selectedUser = event.detail;
        console.log('this.selectedUser.id ==> ' + this.selectedUser.id);
        console.log('this.selectedUser.mainField ==> ' + this.selectedUser.mainField);
        console.log('this.selectedUser.subField ==> ' + this.selectedUser.subField);
        
        this.changeOwner = false
        this.selectedUserName = this.selectedUser.mainField;

        this.recordsFoundTxt = 'We have found the next records with ' + this.selectedUser.mainField + ' as Owner.';

        this.zendeskSearchDone = false;
        this.swellSearchDone = false;
        this.zendeskUserFound = false;
        this.zendeskUserId = '';
        this.swellUserFound = false;
        this.swellUserId = '';
        this.errorMessage = 'Errors: ';

        getZendeskUser({
            "email":this.selectedUser.subField
        })
        .then(result => {
            console.log('Zendesk Result ==> ' + result);
            this.zendeskUserId = result;
            if (this.zendeskUserId != '') {
                this.zendeskUserFound = true;
                this.zendeskCheckboxValue = true;
            } else {
                this.zendeskUserFound = false;
                this.zendeskCheckboxValue = false;
            }
            console.log('this.zendeskUserFound ==> ' + this.zendeskUserFound);
            
            this.zendeskSearchDone = true;
            this.loadingValue += 15;
        })
        .catch(error => {
            this.displayError = true;
            this.errorMessage += 'getZendeskUser Error: ' + error;
        })

        getSwellUser({
            "email":this.selectedUser.subField
        })
        .then(result => {
            console.log('Swell result ==> ' + result);
            this.swellUserId = result;
            if (this.swellUserId != '') {
                this.swellUserFound = true;
                this.swellCheckboxValue = true;
            } else {
                this.swellUserFound = false;
                this.swellCheckboxValue = false;
            }
            console.log('this.swellUserFound ==> ' + this.swellUserFound);
            
            this.swellSearchDone = true;
            this.loadingValue += 15;
        })
        .catch(error => {
            this.displayError = true;
            this.errorMessage += 'getSwellUser Error: ' + error;
        })

        getAccounts({
            "ownerId":this.selectedUser.id
        })
        .then(result => {
            this.accountList = result;
            this.accountsFound = result.length;
            this.loadingValue += 10;
        })

        getContacts({
            "ownerId":this.selectedUser.id
        })
        .then(result => {
            this.contactList = result;
            this.contactsFound = result.length;
            this.loadingValue += 5;
        })

        getOrders({
            "ownerId":this.selectedUser.id
        })
        .then(result => {
            this.orderList = result;
            this.ordersFound = result.length;
            this.loadingValue += 10;
        })

        getOpportunities({
            "ownerId":this.selectedUser.id
        })
        .then (result => {
            this.opportunityList = result;
            this.opportunitiesFound = result.length;
            this.loadingValue += 10;
        })

        getCases({
            "ownerId":this.selectedUser.id
        })
        .then(result => {
            this.caseList = result;
            this.casesFound = result.length;
            this.loadingValue += 10;
        })

        getCampaigns({
            "ownerId":this.selectedUser.id
        })
        .then(result => {
            this.campaignList = result;
            this.campaignsFound = result.length;
            this.loadingValue += 5;
        })

        getDashboards({
            "ownerId":this.selectedUser.id
        })
        .then(result => {
            this.showDashboardResults = false;
            this.dashboardList = [];
            this.dashboardsFound = result.length;
            this.loadingValue += 10;

            if (this.dashboardsFound > 0) {
                let d = [];
                result.forEach(element => {
                    let elt = {};
                    elt.id = element.Id;
                    elt.url = `/${element.Id}`;
                    elt.name = element.Title;

                    d.push(elt);
                });
                this.dashboardList = d;
                this.showDashboardResults = true;
            }

        })

        getCustomMetadataTypes({
            "ownerId":this.selectedUser.id
        })
        .then(result => {
            console.log('getCustomMetadataTypes results => ' + result);
            this.showApexResults = false;
            this.apexList = [];
            this.apexFound = result.length;
            this.loadingValue += 10;

            if (this.apexFound > 0) {
                let a = [];
                result.forEach(element => {
                    let elt = [];
                    elt.id = element.Id;
                    elt.url = `/${element.Id}`;
                    elt.name = element.Label;
                    
                    element.GeneralId__c == this.selectedUser.id ? elt.GeneralId__c = true : elt.GeneralId__c = false;
                    element.NoordhoffId__c == this.selectedUser.id ? elt.NoordhoffId = true : elt.NoordhoffId = false;
                    element.PlantynId__c == this.selectedUser.id ? elt.PlanrynId = true : elt.PlantynId = false;
                    element.LiberId__c == this.selectedUser.id ? elt.LiberId = true : elt.LiberId = false;

                    a.push(elt);
                })
                this.showApexResults = true;
                this.apexList = a;
            }
        })

        console.log('showDashboardResults => ' + this.showDashboardResults);

    }

    handleValueSelectedOnChangeRecordsUser(event) {
        this.changeRecordSelectedUser = event.detail;
        console.log('changeRecordSelectedUser.Id => ' + this.changeRecordSelectedUser.id);
        console.log('changeRecordSelectedUser.name => ' + this.changeRecordSelectedUser.mainField);
        console.log('changeRecordSelectedUser.email => ' + this.changeRecordSelectedUser.subField);
    }

    handleValueSelectedOnChangeDashboardUser(event) {
        this.changeDashboardSelectedUser = event.detail;
        console.log('changeDashboardSelectedUser.Id => ' + this.changeDashboardSelectedUser.id);
        console.log('changeDashboardSelectedUser.name => ' + this.changeDashboardSelectedUser.mainField);
        console.log('changeDashboardSelectedUser.email => ' + this.changeDashboardSelectedUser.subField);
    }

    get zendeskUserFound() {
        return this.zendeskUserFound;
    }

    get swellUserFound() {
        return this.swellUserFound;
    }

    get disableButton() {
        return !(this.zendeskSearchDone && this.swellSearchDone && (!this.changeOwner || this.changeRecordSelectedUser) && (!this.changeDashboardOwner || this.changeDashboardSelectedUser))
    }

    get showChangeRecordOwnerSwitch() {
        return (this.accountsFound + this.contactsFound + this.ordersFound + this.opportunitiesFound + this.casesFound + this.campaignsFound) > 0;
    }

    get showChangeDashboardRecordOwnerSwitch() {
        return (this.dashboardsFound > 0);
    }

    get loadingValueToDisplay() {
        return this.loadingValue;
    }

    get loading() {
        if (this.loadingValue > 0 && this.loadingValue < 100) {
            return true;
        } else {
            return false;
        }
    }

    get loadingTextValue() {
        return this.loaderTxt;
    }

    get displayErrors() {
        return this.displayError;
    }

    get errors() {
        return this.errorMessage;
    }

    get showDbResults() {
        return this.showDashboardResults;
    }

    get showApxResults() {
        return this.showApexResults;
    }

    get isFinished() {
        return this.finished && this.loadingValue >= 100;
    }

    handleZdCheckboxValue() {
        this.zendeskCheckboxValue = !this.zendeskCheckboxValue;
        console.log('Zendesk checkbox ==> ' + this.zendeskCheckboxValue);
    }

    handleSwellCheckboxValue() {
        this.swellCheckboxValue = !this.swellCheckboxValue;
        console.log('Swell checkbox ==> ' + this.swellCheckboxValue);
    }

    handleOwnerCheckboxChange() {
        this.changeOwner = !this.changeOwner;
        console.log('changeOwner => ' + this.changeOwner);
    }

    handleDashboardOwnerCheckboxChange() {
        this.changeDashboardOwner = !this.changeDashboardOwner;
        console.log('changeDashboardOwner => ' + this.changeDashboardOwner);
    }

    handleBack() {
        this.loadingValue = 0;
    }

    handleSubmit() {

        this.loadingValue = 1;
        this.displayError = false;
        this.errorMessage = 'Errors:';

        var loaderValue = 1;

        if (this.zendeskUserFound && this.zendeskCheckboxValue) {
            loaderValue += 1;
        }
        if (this.swellUserFound && this.swellCheckboxValue) {
            loaderValue += 1;
        }
        if (this.changeOwner) {
            if (this.accountsFound > 0) {
            loaderValue += 1;
            }
            if (this.contactsFound > 0) {
                loaderValue += 1;
            }
            if (this.ordersFound > 0) {
                loaderValue += 1;
            }
            if (this.opportunitiesFound > 0) {
                loaderValue += 1;
            }
            if (this.casesFound > 0) {
                loaderValue += 1;
            }
            if (this.campaignsFound > 0) {
                loaderValue += 1;
            }
        }
        

        loaderValue = Math.ceil(100/loaderValue);
        console.log('loaderValue => ' + loaderValue);

        deactivateUser({
            "userId":this.selectedUser.id
        })
        .then(result => {
            console.log('Deactivating User with Id ' + this.selectedUser.id);
            if (result != 'Success') {
                console.log('Unsuccessfull result on User deactivation');
                this.displayError = true;
                this.errorMessage += result;
            }
            this.loadingValue += loaderValue;
        })

        console.log('this.zendeskCheckboxValue => ' + this.zendeskCheckboxValue);
        if (this.zendeskUserFound && this.zendeskCheckboxValue) {
            console.log('suspending Zendesk User with Zendesk Id ' + this.zendeskUserId);
            suspendZendeskUser({
                "userId":this.zendeskUserId
            })
            .then(result => {
                console.log('suspendZendeskUserResult => ' + result);
                if (result == 200) {
                    console.log('Zendesk User suspended');
                }
                this.loadingValue += loaderValue;
            })
        }

        console.log('this.swellCheckboxValue => ' + this.swellCheckboxValue);
        if (this.swellUserFound && this.swellCheckboxValue) {
            console.log('suspending Swell User with Swell Id ' + this.swellUserId);
            deleteSwellUser({
                "userId":this.swellUserId
            })
            .then(result => {
                console.log('deleteSwellUserResult => ' + result);
                if (result == 200) {
                    console.log('Swell User deleted');
                }
                this.loadingValue += loaderValue;
            })
        }
        
        if (this.changeOwner) {
            if (this.accountsFound > 0) {
                updateAccountOwner({
                    "accounts":this.accountList,
                    "newOwnerId":this.changeRecordSelectedUser.id
                })
                .then(result => {
                    console.log('updateAccountOwner Result => ' + result);
                    if (result != 'Success') {
                        console.log('Unsuccessfull result on Account update');
                        this.displayError = true;
                        this.errorMessage += result;
                    }
                    this.loadingValue += loaderValue;
                })
            }
            
            if (this.contactsFound > 0) {
                updateContactOwner({
                    "contacts":this.contactList,
                    "newOwnerId":this.changeRecordSelectedUser.id
                })
                .then(result => {
                    console.log('updateContactOwner Result => ' + result);
                    if (result != 'Success') {
                        console.log('Unsuccessfull result on Contact update');
                        this.displayError = true;
                        this.errorMessage += result;
                    }
                    this.loadingValue += loaderValue;
                })
            }

            if (this.ordersFound > 0) {
                updateOrderOwner({
                    "orders":this.orderList,
                    "newOwnerId":this.changeRecordSelectedUser.id
                })
                .then(result => {
                    console.log('updateOrderOwner Result => ' + result);
                    if (result != 'Success') {
                        console.log('Unsuccessfull result on Order update');
                        this.displayError = true;
                        this.errorMessage += result;
                    }
                    this.loadingValue += loaderValue;
                })
            }

            if (this.opportunitiesFound > 0) {
                updateOpportunityOwner({
                    "opportunity":this.opportunityList,
                    "newOwnerId":this.changeRecordSelectedUser.id
                })
                .then(result => {
                    console.log('updateOpportunityOwner Result => ' + result);
                    if (result != 'Success') {
                        console.log('Unsuccessfull result on Opportunity update');
                        this.displayError = true;
                        this.errorMessage += result;
                    }
                    this.loadingValue += loaderValue;
                })
            }

            if (this.casesFound > 0) {
                updateCaseOwner({
                    "cases":this.caseList,
                    "newOwnerId":this.changeRecordSelectedUser.id
                })
                .then(result => {
                    console.log('updateCaseOwner Result => ' + result);
                    if (result != 'Success') {
                        console.log('Unsuccessfull result on Case update');
                        this.displayError = true;
                        this.errorMessage += result;
                    }
                    this.loadingValue += loaderValue;
                })
            }

            if (this.campaignsFound > 0) {
                updateCampaignOwner({
                    "campaigns":this.campaignList,
                    "newOwnerId":this.changeRecordSelectedUser.id
                })
                .then(result => {
                    console.log('updateCampaignOwner Result => ' + result);
                    if (result != 'Success') {
                        console.log('Unsuccessfull result on Campaign update');
                        this.displayError = true;
                        this.errorMessage += result;
                    }
                    this.loadingValue += loaderValue;
                })
            }
        }
        

        this.finished = true;

    }

    refresh() {
        eval("$A.get('e.force:refreshView').fire();");
    }


}