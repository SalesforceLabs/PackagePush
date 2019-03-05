public with sharing class PackageController extends RestApiClient{

static Boolean debug = true;
Public Static Final String APIVERSION = 'v44.0/';
Public Static Final String BASESOBJECTPATH = '/services/data/' + APIVERSION;
Public Static Final String SOBJECTPATH = BASESOBJECTPATH + 'sobjects/';
Public Static Final String PUSHPACKAGEPATH = SOBJECTPATH + 'packagepushrequest/';
Public Static Final String PACKAGEPUSHJOB = SOBJECTPATH + 'packagepushjob/';
Public Static Final String TREECREATEPATH = BASESOBJECTPATH + 'composite/tree/packagepushjob';
Public Static Final String STATUSPENDING = '{"Status" :"Pending"}';
Public Static Final String STATUSCANCELED = '{"Status" :"Canceled"}';

public PackageController(){

}

public PackageController(String nc){
    super(nc);
}

@AuraEnabled(Cacheable=false)
public static RestResult schedulePush(String pkgid, String packageverid, String starttime, String orgs) {
    
    RestResult retStatus = new RestResult();
    
try{
    System.debug('Apex SchedulePush called');

    String setnc = getNC(pkgid);
    System.debug('Apex SchedulePush nc=' + setnc);

    List<String> selectedIdsList = new List<String>();
    Object[] values = (Object[])System.JSON.deserializeUntyped(orgs);
    if(values.size()>0){         
        for (Object id : values) {
            selectedIdsList.add(string.valueof(id) );
        }
    }
    
    //Step 1
    String req = '{"PackageVersionId" : "' + packageverid + '" ,"ScheduledStartTime" : "' + starttime + '"}';
    String res = new PackageController(setnc).postreq(PUSHPACKAGEPATH, req);
    logit('SchedulePush res=' + res);
    
    Map<String, Object> pr = (Map<String, Object>)Json.deserializeUntyped(res);
    System.debug('jp=' + pr.get('id') + pr.get('success') + '\n');
    
    if((boolean)pr.get('success')){
        String pushreqid = (String) pr.get('id');        
        
        //Step 2
        PushRecords recs = new PushRecords();
        for(String org : selectedIdsList){
            PushRecord o = new PushRecord();
            o.PackagePushRequestId = pushreqid;
            o.SubscriberOrganizationKey  = org;
            recs.records.add(o);
            PushRecordAttribute pa = new PushRecordAttribute();
            pa.ptype = 'PackagePushJob';
            pa.referenceId = org;
            o.attributes = pa;
        }
        
        req = JSON.serialize(recs);
        req = req.replace('ptype', 'type');
        System.debug('job req=' + req + '\n');
        
        res = new PackageController(setnc).postreq(TREECREATEPATH, req);
        logit('Createjob res=' + res);
        
        ////Step 3 start the job
        res = new PackageController(setnc).patchreq(PUSHPACKAGEPATH + pushreqid, STATUSPENDING);
        logit('STATUSPENDING res=' + res);
        
        // CancelPush( pushreqid);
        //  System.debug('Push canceled');
    }
    
    logit('SchedulePush change to Pending status, res=' + res);

    retStatus.status = true;
    retStatus.message = 'Schedule success';
}catch(Exception e){
    retStatus.status = false;
    retStatus.message = e.getMessage();
}
    
    return retStatus;     
}

//0DVB0000000TN9p
@AuraEnabled(Cacheable=false)
public static RestResult CancelPush(String pkgid, String pushreqid) {
RestResult retStatus = new RestResult();

    try{

        String setnc = getNC(pkgid);
        System.debug('Apex SchedulePush nc=' + setnc);

        String res = new PackageController(setnc).patchreq(PUSHPACKAGEPATH + pushreqid, STATUSCANCELED);
        logit('CancelPush res=' + res);
            retStatus.status = true;
            retStatus.message = 'Schedule cancel';
        }catch(Exception e){
            retStatus.status = false;
            retStatus.message = e.getMessage();
        }
    
        return retStatus;     
}

//Cross-org call    
@AuraEnabled(Cacheable=true)
public static String getPendingJobs(String pkgid) {

    String setnc = getNC(pkgid);
    System.debug('Apex SchedulePush nc=' + setnc);

    String q = 'SELECT id, Status, ScheduledStartTime, PackageVersionId FROM PackagePushRequest';
    String res = new PackageController(setnc).query(q);
    logit('getPendingJobs res=' + res);
    
    return res;
}
  
//Cross-org call    
@AuraEnabled(Cacheable=true)
public static String getFromPkgOrgPackageVersions( String pkgid, String pkgverid) {
    
    String setnc = getNC(pkgid);
    System.debug('Apex SchedulePush nc=' + setnc);

    String q = 'SELECT BuildNumber,Id,MajorVersion,MetadataPackageId,MinorVersion,Name,PatchVersion,ReleaseState FROM MetadataPackageVersion';
    String res = new PackageController(setnc).query(q);
    logit('getFromPkgOrgPackageVersions res=' + res);
    
    return res;
}

//Cross-org call
@AuraEnabled(Cacheable=true)
public static String getPkgOrgDetails(String pkgid, String whichorg) {

    String setnc = getNC(pkgid);
    System.debug('Apex SchedulePush nc=' + setnc);

    String q = 'SELECT Id, TimeZoneSidKey, DefaultLocaleSidKey FROM Organization';
    String res = new PackageController(setnc).query(q);
    logit('getPkgOrgDetails res=' + res);
    
    return res;
}
    
@AuraEnabled(Cacheable=true)
public static sfLma__License__c[] getLicenseDetails() {

    List<sfLma__License__c> recs =
        [SELECT Id, sfLma__License_Status__c, sfLma__Package__r.sfLma__Package_ID__c, sfLma__Package_Version__r.sfLma__Version_ID__c, sfLma__Org_Status_Formula__c,sfLma__Org_Status__c,sfLma__Status__c,sfLma__Subscriber_Org_ID__c,sfLma__Subscriber_Org_Is_Sandbox__c,sfLma__Trial_Expiration_Date__c
        FROM sfLma__License__c];

    return recs;
}

@AuraEnabled(Cacheable=true)
public static sfLma__Package__c[] getPackages() {
    List<sfLma__Package__c> recs =
        [SELECT Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,OwnerId,sfLma__Developer_Name__c,sfLma__Developer_Org_ID__c,sfLma__Help__c,sfLma__Latest_Version__c,sfLma__Lead_Manager__c,sfLma__Package_ID__c,sfLma__Release_Date__c FROM sfLma__Package__c];
    return recs;
}

@AuraEnabled(Cacheable=true)
public static sfLma__Package_Version__c[] getPackageVersions() {
    List<sfLma__Package_Version__c> recs =
        [SELECT Id,IsDeleted,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,sfLma__Help__c,sfLma__Is_Beta__c,sfLma__Package__c, sfLma__Package__r.sfLma__Package_ID__c,sfLma__Release_Date__c,sfLma__Sequence__c,sfLma__Version_ID__c,sfLma__Version__c FROM sfLma__Package_Version__c];
    return recs;
}

//Helper
@AuraEnabled(Cacheable=true)
public static String getNC(String pkgid) {
    
    logit('getNC pkgid=' + pkgid);

    PackageNcMapping__c nc =
        [SELECT Id, Name, IsActive__c, NamedCredential__c, RelatedPackage__c FROM PackageNcMapping__c where RelatedPackage__r.sfLma__Package_ID__c =: pkgid];

    logit('getNC got nc=' + nc);

    return nc.NamedCredential__c;
}
    
    Public static Void logit(Object o){
        if(debug){
            System.debug('\n' + o + '\n');
        }
    }   

Public class RestResult {
    public RestResult(){
        this.status= false;
        this.message = 'NONE';
    }
    @AuraEnabled Public Boolean status { get; set; }
    @AuraEnabled Public String message { get; set; }
    
}

Public class PkgVersion {
    @AuraEnabled public String Name { get; set; }
    @AuraEnabled public String Id { get; set; }
    @AuraEnabled public String ReleaseState { get; set; }
    @AuraEnabled public Integer MajorVersion { get; set; }
    @AuraEnabled public Integer MinorVersion { get; set; }
    @AuraEnabled public Integer PatchVersion { get; set; }
    @AuraEnabled public Integer BuildNumber { get; set; }

    public PkgVersion(String name, String id, String releaseState, Integer majorVersion, Integer minorVersion, Integer patchVersion, Integer buildNumber) {
      this.id = id;
      this.name = name;
      this.ReleaseState = releaseState;
      this.MajorVersion = majorVersion;
      this.MinorVersion = minorVersion;
      this.PatchVersion = patchVersion;
      this.BuildNumber = buildNumber;
    }
  }


Public class Subscriber {
    @AuraEnabled public String Id { get; set; }
    @AuraEnabled public String InstalledStatus { get; set; }
    @AuraEnabled public String MetadataPackageVersionId { get; set; }
    @AuraEnabled public String OrgKey { get; set; }
    @AuraEnabled public String OrgName { get; set; }
    @AuraEnabled public String OrgType { get; set; }
    @AuraEnabled public String OrgStatus { get; set; }
    @AuraEnabled public String InstanceName { get; set; }
}

Public class Pkg {
    @AuraEnabled Public Id id { get; set; }
    @AuraEnabled Public String Name { get; set; }
    @AuraEnabled Public List<PkgVersion> pkgVersions { get; set; }
}

public class LicenseDetail {

    @AuraEnabled public Subscriber subscriber { get; set; }
    @AuraEnabled public Pkg pkg { get; set; }
}

    Public class PushRecords{
        public List<PushRecord> records = new List<PushRecord>();
    }   
    Public class PushRecord{
        public String PackagePushRequestId;
        public String SubscriberOrganizationKey;
        public PushRecordAttribute attributes = new PushRecordAttribute();
    }   
    Public class PushRecordAttribute{
        public String ptype;
        public String referenceId;
    } 
    
    
}