import {
    LightningElement,
    api,
    track
} from 'lwc';

import getOrgStatusByNCRecordId from '@salesforce/apex/PackageController.getOrgStatusByNCRecordId';

export default class PackageNCTest extends LightningElement {

    @api recordId;

    @track status;

    connectedCallback() {

        window.console.log("OrgConnectStatus recordId =" + this.recordId);

        getOrgStatusByNCRecordId({
            "recid": this.recordId
        }).then((result) => {

            window.console.log("OrgConnectStatus result =" + result);

            if (result == null) {
                this.status = 'Not Connected';
            } else {

                let orgstatus = JSON.parse(result);

                if (orgstatus != null && orgstatus.totalSize > 0) {
                    this.status = 'Connected';
                } else {
                    this.status = 'Not Connected';
                }
            }

        });

    }

}