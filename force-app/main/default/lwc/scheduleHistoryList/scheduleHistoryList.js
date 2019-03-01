import {
    LightningElement,
    track,
    wire
} from 'lwc';

import getPendingJobs from '@salesforce/apex/PackageController.getPendingJobs';
import cancelPush from '@salesforce/apex/PackageController.CancelPush';
import {
    refreshApex
} from '@salesforce/apex';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import {
    CurrentPageReference
} from 'lightning/navigation';

import {
    registerListener,
    unregisterAllListeners,
    fireEvent
} from 'c/pubsub';


export default class ScheduleHistoryList extends LightningElement {

    @track name = 'Package Push Schedule';

    actions = [{
            label: 'Show details',
            name: 'show_details'
        },
        {
            label: 'Delete',
            name: 'delete'
        }
    ]

    @track columns = [{
            label: 'Id',
            fieldName: 'Id',
            type: 'text'
        },
        {
            label: 'ScheduledStartTime',
            fieldName: 'ScheduledStartTime',
            type: 'text'
        },
        {
            label: 'Cancel',
            type: 'button',
            initialWidth: 135,
            typeAttributes: {
                label: 'Cancel',
                name: 'Cancel',
                title: 'Cancel'
            }
        },
    ]

    @track historycolumns = [{
            label: 'Id',
            fieldName: 'Id',
            type: 'text'
        },
        {
            label: 'ScheduledStartTime',
            fieldName: 'ScheduledStartTime',
            type: 'text'
        },
        {
            label: 'Status',
            fieldName: 'Status',
            type: 'text'
        },
    ]


    @wire(CurrentPageReference) pageRef;

    @wire(getPendingJobs, {})
    getPendingJobs;

    connectedCallback() {
        //        this.boundPushScheduledHandler = this.handlePushScheduled.bind(this);

        registerListener('ScheduledEvent', this.handlePushScheduled, this);

        //registerListener('ScheduledEvent', this.boundPushScheduledHandler);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
        //unregisterAllListeners('ScheduledEvent', this.boundPushScheduledHandler);
    }

    get data() {

        window.console.log('*** this.getPendingJobs=' + JSON.stringify(this.getPendingJobs));

        if (!this.getPendingJobs || !this.getPendingJobs.data) {
            return [];
        }
        window.console.log('*** this.getPendingJobs.data=' + JSON.stringify(this.getPendingJobs.data));

        var data = JSON.parse(this.getPendingJobs.data);
        window.console.log('*** this.getPendingJobs records=' + JSON.stringify(data));

        var records = data.records.filter(o => {
            return o.Status === 'Pending';
        });

        return records;

    }

    get historydata() {

        window.console.log('*** this.historydata=' + JSON.stringify(this.getPendingJobs));

        if (!this.getPendingJobs || !this.getPendingJobs.data) {
            return [];
        }
        window.console.log('*** this.historydata.data=' + JSON.stringify(this.getPendingJobs.data));

        var data = JSON.parse(this.getPendingJobs.data);
        window.console.log('*** this.historydata records=' + JSON.stringify(data));

        var records = data.records.filter(o => {
            return o.Status !== 'Pending';
        });

        return records;
    }

    doCancelPush(pushid) {

        cancelPush({
            pushreqid: pushid
        }).then((result) => {
            window.console.log("cancelPush got results");

            window.console.log("cancelPush results=" + JSON.stringify(result));
            if (result.status) {
                window.console.log("cancelPush results in success");
                const evt = new ShowToastEvent({
                    title: 'Scheduled Push cancel',
                    message: 'Canceled Successfully!',
                    variant: 'success',
                });
                this.dispatchEvent(evt);

                refreshApex(this.getPendingJobs);

            } else {

                const evt = new ShowToastEvent({
                    title: 'Scheduled Push cancel failed',
                    message: result.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);

            }
        });
    }

    fireCanceledChangeEvent() {
        const cancelinfo = {};
        //pubsub.fire('ScheduleCancelEvent', cancelinfo);
    }

    handleRowAction(event) {
        this.doCancelPush(event.detail.row.Id);
        window.console.log('**handleRowAction, val=' + JSON.stringify(event.detail.row.Id));
    }

    handlePushScheduled(event) {
        //this.doCancelPush(event.detail.row.Id);
        window.console.log('**handlePushScheduled=' + JSON.stringify(event));
        refreshApex(this.getPendingJobs);
    }

    showNotification(titleText, messageText, messageType) {

        const evt = new ShowToastEvent({
            title: titleText,
            message: messageText,
            variant: messageType,
        });
        this.dispatchEvent(evt);

    }

}