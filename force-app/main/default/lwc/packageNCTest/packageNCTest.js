import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';

import {
    getRecord
} from 'lightning/uiRecordApi';

import getPkgOrgDetails from '@salesforce/apex/PackageController.getPkgOrgDetails';

const fields = [
    'PackageNcMapping__c.Name',
    'PackageNcMapping__c.RelatedPackage__c',
    'PackageNcMapping__c.NamedCredential__c',
    'PackageNcMapping__c.IsActive__c'
];

export default class PackageNCTest extends LightningElement {

    @api recordId;

    @wire(getRecord, {
        recordId: '$recordId',
        fields
    })
    pkgncmappings;

    @wire(getPkgOrgDetails, {
        "whichorg": ""
    })
    getOrgDetails({
        error,
        data
    }) {
        if (error) {
            this.orgTestResult = 'Failed to connect';
            window.console.log('** Get org details error=' + JSON.stringify(error));
        }
        if (data) {
            this.orgTestResult = 'Connected';
            window.console.log('** Get org details success!');
        }
    }

    get name() {

        window.console.log('** name=' + JSON.stringify(this.pkgncmappings.data));
        if (this.pkgncmappings.data) {
            return this.pkgncmappings.data.fields.IsActive__c.value;
        }

    }

}