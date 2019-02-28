import {
    LightningElement,
    track,
    wire
} from 'lwc';

import getPendingJobs from '@salesforce/apex/PackageController.getPendingJobs';
import cancelPush from '@salesforce/apex/PackageController.CancelPush';

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

    @wire(getPendingJobs, {})
    getPendingJobs;

    connectedCallback() {
        this.boundPushScheduledHandler = this.handlePushScheduled.bind(this);
        //registerListener('ScheduledEvent', this.boundPushScheduledHandler);
    }

    disconnectedCallback() {
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

    async doCancelPush(pushid) {
        await cancelPush({
            pushreqid: pushid
        }).then((result) => {
            window.console.log("cancelPush got results");

            window.console.log("cancelPush results=" + JSON.stringify(result));
            if (result.status) {
                /*
                showToast({
                    title: 'Scheduled Push canceled!',
                    message: 'Successfully!',

                });
                //this.fireCanceledChangeEvent();
                refreshApex(this.getPendingJobs);
                */
            } else {
                /*
                showToast({
                    title: 'Scheduled Push cancel failed',
                    message: result.message,
                    variant: 'error',
                });
                */
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
        //refreshApex(this.getPendingJobs);
    }

}