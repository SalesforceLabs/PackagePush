import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';

/** Wire adapter for list views. */
import {
    getListUi
}
from 'lightning/uiListApi';

import {
    CurrentPageReference
} from 'lightning/navigation';

import {
    fireEvent
} from 'c/pubsub';


/** LICENSE Schema. */
import LICENSE_OBJECT_NAME_FIELD from '@salesforce/schema/sfLma__License__c.Name';
import LICENSE_OBJECT from '@salesforce/schema/sfLma__License__c';

import getLicenseDetails from '@salesforce/apex/PackageController.getLicenseDetails';
import getPackages from '@salesforce/apex/PackageController.getPackages';
import getPackageVersions from '@salesforce/apex/PackageController.getPackageVersions';
import getFromPkgOrgPackageVersions from '@salesforce/apex/PackageController.getFromPkgOrgPackageVersions';
import schedulePush from '@salesforce/apex/PackageController.schedulePush';
import getPkgOrgDetails from '@salesforce/apex/PackageController.getPkgOrgDetails';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';

import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

/**
 * Gets a field value by recursing through spanned records.
 * @param {Object} record The record holding the field.
 * @param {string[]} field Field to retrieve.
 */

function getFieldValue(record, field) {
    const f = field.shift();

    window.console.log('**getFieldValue record=' + record + ', field=' + field + ',f=' + f);

    if (record == null) {
        return null;
    }

    const value = record.fields[f].value;

    if (field.length === 0) {
        return value;
    }
    return getFieldValue(value, field);
}

export default class SchedulePush extends LightningElement {

    @api searchBarIsVisible = false;

    @track outlierdata = [];
    @track alldata = [];
    @track data = [];
    @track outlierdata = [];
    @track selectedData = [];
    @track columns = [];
    @track outliercolumns = [];
    @track message;
    @track listViewName;
    @track selectedRows = [];
    @track selectedRowsCount;
    @track isLoading;
    @track pkgOptions = [];
    @track pkgVersionOptions = [];
    @track showoutlier = false;
    @track disablePushBtn = false;
    @track tz = "";
    @track scheduletime = "2019-12-12T12:00:00Z";
    @track locale = "";
    @track curtzdt = "";

    selpkgid;
    selpkgver;
    pkgVerMap = new Map();

    validOrgStatus = ["TRIAL", "SIGNING_UP", "ACTIVE", "FREE", "Trial", "Active", "Free"];
    validLicenseStatus = ["Trial", "Active", "TRIAL", "ACTIVE", "FREE"];

    @wire(CurrentPageReference) pageRef;

    @wire(getPkgOrgDetails, {
        pkgid: "$selpkgid"
    })
    getPkgOrgDetails(value) {

        window.console.log('**getPkgOrgDetails =' + JSON.stringify(value));

        if (value.error) {
            this.showError({
                title: 'Error Loading Org details',
                message: value.error.message,
            });
        } else if (value.data) {
            //window.console.log('** getPkgOrgDetails data=' + JSON.stringify(value.data));
            var orginfo = JSON.parse(value.data);
            //window.console.log('** getPkgOrgDetails data=' + JSON.stringify(orginfo));
            //window.console.log('** getPkgOrgDetails orginfo=' + orginfo.records[0].TimeZoneSidKey);
            this.tz = orginfo.records[0].TimeZoneSidKey;
            this.locale = orginfo.records[0].DefaultLocaleSidKey;

            var dtnow = Date.now(); // Results below assume UTC timezone - your results may vary

            const options = {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                second: 'numeric',
                hour12: false,
                timeZone: this.tz
            };

            window.console.log("Timezone=" + this.tz + ", locale=" + this.locale);

            //TBD to fix issue with en_US
            this.locale = "en-US";

            this.curtzdt = new Intl.DateTimeFormat(this.locale, options).format(dtnow);

            window.console.log("Timezone=" + this.tz + ", locale=" + this.locale + ", currenttime=" + this.curtzdt);

        }

        // window.console.log('**packageOptions options=' + JSON.stringify(this.pkgOptions));
    }

    @wire(getLicenseDetails, {})
    wiredLicenseDetails;

    @wire(getPackages, {})
    pkgs(value) {
        this.pkgOptions = [];

        //window.console.log('**getPackages =' + JSON.stringify(value));

        if (value.error) {
            this.showError({
                title: 'Error Loading Packages',
                message: value.error.message,
            });
        } else if (value.data) {
            //window.console.log('** getPackages data=' + JSON.stringify(value.data));

            value.data.forEach(o => {
                this.pkgOptions.push({
                    value: o.sfLma__Package_ID__c,
                    label: o.Name,
                });
            });
        }

        // window.console.log('**packageOptions options=' + JSON.stringify(this.pkgOptions));
    }

    @wire(getPackageVersions, {})
    pkgVersions;

    @wire(getListUi, {
        objectApiName: LICENSE_OBJECT_NAME_FIELD,
    })
    listviews;

    /**
     * Load the list of available LICENSES
     */
    @wire(getListUi, {
        objectApiName: LICENSE_OBJECT,
        listViewApiName: '$listViewName',
        pageSize: 2000
    })
    records({
        error,
        data
    }) {
        if (error) {
            window.console.log('** error=' + JSON.stringify(error));
        }

        if (data) {

            // extract the column info
            this.columns = data.info.displayColumns.map(column => {
                return {
                    label: column.label,
                    fieldName: column.fieldApiName,
                    type: 'text',
                };
            });

            this.outliercolumns = data.info.displayColumns.map(column => {
                return {
                    label: column.label,
                    fieldName: column.fieldApiName,
                    type: 'text',
                };
            });

            this.data = this.alldata = data.records.records.map(record => {
                window.console.log('Got record=' + JSON.stringify(record));
                return this.columns.reduce(
                    (row, column) => {
                        const field = column.fieldName.split('.');
                        window.console.log('Got record=' + record + ' field=' + field);
                        row[column.fieldName] = getFieldValue(record, field);
                        return row;
                    }, {
                        id: record.id,
                    },
                );
            });

            this.outliercolumns.push({
                label: "Outlier-Reason",
                fieldName: "OutlierReason",
                type: 'text',
            });

            window.console.log('LICENSES alldata =' + JSON.stringify(this.alldata));
        } else if (error) {

            const evt = new ShowToastEvent({
                title: 'Error Loading License List',
                message: error,
                variant: 'error',
            });
            this.dispatchEvent(evt);

        }
    }

    enrichdata(listviewdata) {
        //Create MAP of Id to real packageId
        window.console.log('**enrichdata this.listviewdata=' + JSON.stringify(listviewdata));
        window.console.log('**enrichdata wiredLicenseDetails=' + JSON.stringify(this.wiredLicenseDetails.data));

        listviewdata.forEach(licview => {
            this.wiredLicenseDetails.data.forEach(licmaster => {

                if (licview.Id === licmaster.id) {
                    licview["pkgid"] = licmaster.sfLma__Package__r.sfLma__Package_ID__c;
                    licview["orgid"] = licmaster.sfLma__Subscriber_Org_ID__c;
                }
            });
        });

        window.console.log('**enrichdata this.listviewdata.data=' + JSON.stringify(listviewdata));

    }

    filterdata(alldata) {
        this.data = alldata;
    }

    get listviewOptions() {
        //const packageList = this.packageList;
        //const packageVersionList = this.packageVersionList;

        let options = [];

        if (!this.listviews || !this.listviews.data) {
            return [];
        }

        //  window.console.log('**comboboxOptions=' + JSON.stringify(this.listviews.data));

        this.listviews.data.lists.forEach(o => {
            options.push({
                value: o.apiName,
                label: o.label,
            });
        });

        //       window.console.log('**options=' + JSON.stringify(options));
        return options;
    }

    connectedCallback() {}

    disconnectedCallback() {}

    listviewHandler(event) {
        window.console.log('**listviewHandler, val=' + event.detail.value);

        let selListView = event.detail.value;
        if (selListView === 'All') {
            selListView = 'sfLma__All';
        } else {
            selListView = 'schedulepkg__' + selListView;
        }
        window.console.log('**listviewHandler, new val=' + event.detail.value);

        this.listViewName = selListView;
    }

    packageHandler(event) {
        window.console.log('**packageHandler, val=' + event.detail.value);
        this.selpkgid = event.detail.value;

        this.firePackageSelectedEvent();

        //update pkgVersionList
        this.pkgVersionOptions = [];

        if (this.pkgVersions.data) {
            //window.console.log('** getPackages data=' + JSON.stringify(this.pkgVersions.data));

            let filteredPkgVersions = this.pkgVersions.data.filter(ver => {
                return ver.sfLma__Package__r.sfLma__Package_ID__c === event.detail.value;
            });

            //window.console.log('** filteredPkgVersions=' + JSON.stringify(filteredPkgVersions));

            filteredPkgVersions.forEach(o => {
                this.pkgVersionOptions.push({
                    value: o.sfLma__Version_ID__c,
                    label: o.Name,
                });
            });
        }
    }

    getPkgOrgVersions() {
        window.console.log("getPkgOrgVersions start");
        getFromPkgOrgPackageVersions({
            pkgid: this.selpkgid
        }).then((result) => {

            //window.console.log("getFromPkgOrgPackageVersions result=" + JSON.stringify(result));
            //window.console.log("getFromPkgOrgPackageVersions data=" + JSON.stringify(this.data));
            window.console.log("Inside getFromPkgOrgPackageVersions result");

            result = JSON.parse(result);
            //let's process the filters
            this.pkgVerMap = new Map();
            result.records.forEach(data => {
                let strVernum = String(data.MajorVersion) + String(data.MinorVersion) + String(data.PatchVersion);
                let vernum = Number(strVernum);
                // window.console.log("data.Id" + data.Id + ", ver=" + vernum);
                this.pkgVerMap.set(data.Id, vernum);
            });

            //window.console.log('this.alldata=' + JSON.stringify(this.alldata));

            window.console.log("before licview");

            this.alldata.forEach(licview => {
                // window.console.log("licview=" + JSON.stringify(licview));

                this.wiredLicenseDetails.data.forEach(licmaster => {
                    //window.console.log("licmaster=" + JSON.stringify(licmaster));
                    if (licview.id === licmaster.Id) {
                        //   window.console.log("licview.Id=" + licview.id + " verid=" + licmaster.sfLma__Package_Version__r.sfLma__Version_ID__c);
                        licview["pkgid"] = licmaster.sfLma__Package__r.sfLma__Package_ID__c;
                        licview["pkgverid"] = licmaster.sfLma__Package_Version__r.sfLma__Version_ID__c;
                        licview["orgid"] = licmaster.sfLma__Subscriber_Org_ID__c;
                        licview["orgstatus"] = licmaster.sfLma__License_Status__c;
                        licview["licstatus"] = licmaster.sfLma__Org_Status_Formula__c;
                    }
                });
            });

            //window.console.log("getFromPkgOrgPackageVersions pkgVerMap size=" + JSON.stringify(this.pkgVerMap.size));
            //  window.console.log("getFromPkgOrgPackageVersions all data=" + JSON.stringify(this.alldata));

            window.console.log("before outlier");
            let outlierliceids = [];

            let versionNotCompatibleData = this.alldata.filter(data => {
                let licpkgvernum = this.pkgVerMap.get(data.pkgverid);
                let selpkgvernum = this.pkgVerMap.get(this.selpkgver);

                /*
                window.console.log("lic pkgverid" + data.pkgverid + ", val=" + licpkgvernum);
                window.console.log("sel pkgverid" + this.selpkgver + ", val=" + selpkgvernum);
                window.console.log("orgstatus=" + data.orgstatus);
                window.console.log("licstatus=" + data.licstatus);
                */

                data["OutlierReason"] = "";
                let isGood = true;

                if (!(licpkgvernum < selpkgvernum)) {
                    data["OutlierReason"] = data["OutlierReason"] +
                        "VERSION-NOT-ELIGIBLE";
                    isGood = false;
                }

                if (!this.validOrgStatus.includes(data.orgstatus)) {

                    data["OutlierReason"] = data["OutlierReason"] + " OrgStatusNotValid-" + data.orgstatus;
                    //window.console.log("*orgstatus not valid=" + data.orgstatus);
                    isGood = false;
                }

                if (!this.validLicenseStatus.includes(data.licstatus)) {
                    data["OutlierReason"] = data["OutlierReason"] + " LicenseStatusNotValid-" + data.licstatus;
                    //window.console.log("*licstatus not valid=" + data.licstatus);
                    isGood = false;
                }

                if (!isGood) {
                    outlierliceids.push(data.id);
                }

                return (!isGood);
            });

            //window.console.log("outlierliceids=" + outlierliceids);
            window.console.log("before goodData");

            let goodData = this.alldata.filter(data => {
                let licpkgvernum = this.pkgVerMap.get(data.pkgverid);
                let selpkgvernum = this.pkgVerMap.get(this.selpkgver);

                // window.console.log("lic id" + data.id);
                // window.console.log("lic pkgverid" + data.pkgverid + ", val=" + licpkgvernum);
                // window.console.log("sel pkgverid" + this.selpkgver + ", val=" + selpkgvernum);

                if (outlierliceids.includes(data.id)) {
                    return false;
                } else {
                    return true;
                }
            });

            window.console.log("after goodData");

            //   window.console.log("getFromPkgOrgPackageVersions alldata=" + JSON.stringify(this.alldata));
            //   window.console.log("getFromPkgOrgPackageVersions tempData=" + JSON.stringify(goodData));

            this.data = goodData;
            this.outlierdata = versionNotCompatibleData;

            window.console.log("packageVersionHandler selectedRows length=" + JSON.stringify(this.selectedRows.length));

        });
    }

    SchedulePushUpgrade() {
        //var scheduletime = "2018-10-10T21:00:00";
        //scheduletime = "2019-08-afafa24T21:00:00";

        // scheduletime = this.curtzdt;
        // window.console.log("async SchedulePushUpgrade real scheduletime=" + scheduletime);

        var scheduletime = this.scheduletime;

        var orgids = [];
        for (var i = 0; i < this.selectedRows.length; i++) {
            orgids.push(this.selectedRows[i]);
        }
        var orgidjson = JSON.stringify(orgids);

        //   window.console.log("async SchedulePushUpgrade this.selpkgver" + this.selpkgver);

        //var temprows = ["00DB0000000PSU8"];
        //accountId: this.recordId,
        //String packageverid, String starttime, String orgs
        schedulePush({
            pkgid: this.selpkgid,
            packageverid: this.selpkgver,
            starttime: scheduletime,
            orgs: orgidjson
        }).then((result) => {
            // window.console.log("getFromPkgOrgPackageVersions result=" + JSON.stringify(result));
            //  window.console.log("getFromPkgOrgPackageVersions data=" + JSON.stringify(this.data));
            //   window.console.log("SchedulePushUpgrade got results");
            //result = JSON.parse(result);
            window.console.log("SchedulePushUpgrade results=" + JSON.stringify(result));
            if (result.status) {

                this.firePushScheduledEvent();

                const evt = new ShowToastEvent({
                    title: 'Scheduled Push upgrade',
                    message: 'Successfully!',
                    variant: 'success',
                });
                this.dispatchEvent(evt);

            } else {

                const evt = new ShowToastEvent({
                    title: 'Scheduled Push upgrade failed',
                    message: result.message,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
        });
    }

    handledt(event) {
        window.console.log("*** datetime change=," + JSON.stringify(event.detail.value));
        this.scheduletime = event.detail.value;
    }

    handlePush(event) {
        //    window.console.log("push start, this.selpkgver=" + this.selpkgver + " this.selectedRows" + this.selectedRows);
        window.console.log("*** push schedule datetime," + this.scheduletime);

        if (!(this.selectedRows && this.selectedRows.length > 0)) {
            const evt = new ShowToastEvent({
                title: 'No records selected',
                message: 'Please select subscriber records',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return;
        }

        if (this.selpkgver && this.selectedRows && this.selectedRows.length > 0) {
            this.SchedulePushUpgrade();
            //  Let's reset selections
            this.selpkgver = null;
            this.data = [];
            this.outlierdata = [];
        }

        window.console.log("push end");
    }

    packageVersionHandler(event) {
        //window.console.log('**packageVersionHandler, val=' + event.detail.value);
        this.selpkgver = event.detail.value;

        window.console.log("selpkgid=" + this.selpkgid + ",selpkgver=" + this.selpkgver);
        this.getPkgOrgVersions();

        window.console.log("packageVersionHandler refreshed");

    }

    rowSelected(event) {
        this.selectedRowsCount = event.detail.selectedRows.length;

        this.selectedRows = event.detail.selectedRows.map(o => o.orgid);
        window.console.log("packageVersionHandler selectedRows=" + JSON.stringify(this.selectedRows));
    }

    searchKeyChangeHandler(event) {
        /*
        const searchKey = event.target.value.toLowerCase();
        this.selectedProducts = this.products.filter(product =>
            getFieldValue(product, NAME_FIELD)
            .value.toLowerCase()
            .includes(searchKey),
        );
        */
    }

    firePushScheduledEvent() {
        const scheduleinfo = {};
        fireEvent(this.pageRef, 'ScheduledEvent', scheduleinfo);
    }

    firePackageSelectedEvent() {
        const packageinfo = {
            "pkgid": this.selpkgid
        };
        fireEvent(this.pageRef, 'PackageSelected', packageinfo);
    }

    get zeroSelectedRecords() {
        return this.selectedData.length === 0;
    }

    get hasData() {
        return !!(this.columns && this.data && this.data.length > 0 && (!this.showoutlier));
    }

    get hasNoData() {
        return !!(this.columns && this.data && this.data.length === 0);
    }

    handleToggle() {
        this.showoutlier = !this.showoutlier;
    }

    showNotification(titleText, messageText, messageType) {
        const evt = new ShowToastEvent({
            title: titleText,
            message: messageText,
            variant: messageType
        });
        this.dispatchEvent(evt);
    }

}