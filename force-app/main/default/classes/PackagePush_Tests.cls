@IsTest
private class PackagePush_Tests {

public static final String PKGID = '0331U000000Eif5QAC';
public static final String PKGVERID = '04t1U000006CEynQAG';
public static final String SUBSCRIBERID = '00DB0000000ThCi';
public static final String SCHEDULESTARTTIME = '2019-12-12T12:00:00.000+0000';
public static final String SUBSCRIBERIDJSON = '["00DB0000000ThCi"]';


@testSetup static void setup() {

  System.debug('PackagePush_Tests setup called');

  sfLma__Package__c pkg = (sfLma__Package__c) TestFactory.createSObject(new sfLma__Package__c(sflma__Developer_Org_ID__C='00D6A0000002p1kUAA', sflma__Package_ID__c=PKGID), true);
  sfLma__Package_Version__c pkgver = (sfLma__Package_Version__c) TestFactory.createSObject(new sfLma__Package_Version__c(sflma__package__c=pkg.id, sflma__Version_ID__c=PKGVERID), true);
  sfLma__License__c license = (sfLma__License__c) TestFactory.createSObject(new sfLma__License__c(sflma__package__c=pkg.id, sflma__Package_Version__c=pkgver.id, sflma__Subscriber_org_Id__c='00D6A0000003kIp'), true);
  
  PackageNcMapping__c nc = new PackageNcMapping__c();
  //nc.Name = 'nc1';
  nc.IsActive__c = true;
  nc.NamedCredential__c = 'nc1';
  nc.RelatedPackage__c = pkg.Id;
  insert nc;


}

//local data
static TestMethod void test_getNC(){
  String nc = PackageController.getNC(PKGID);
  System.assertNotEquals(nc, null);
}

//local data
static TestMethod void test_getPackages(){
  sfLma__Package__c[] res = PackageController.getPackages();
  System.assertNotEquals(res, null);
}

//local data
static TestMethod void test_getPackageVersions(){
  sfLma__Package_Version__c[] res = PackageController.getPackageVersions();
  System.assertNotEquals(res, null);
}

//local data
static TestMethod void test_getLicenseDetails(){
  sfLma__License__c[] res = PackageController.getLicenseDetails();
  System.assertNotEquals(res, null);
}


  static TestMethod void test_schedulePush(){
    String resbody1 = '{"id":"0DV1U0000008r2L","success":true}'; 
    CalloutMock mock = CalloutMock.simpleSuccess(resbody1);    
    Test.setMock(HttpCalloutMock.class, mock);
    Test.startTest();
    PackageController.RestResult res = PackageController.schedulePush(PKGID, PKGVERID, SCHEDULESTARTTIME, SUBSCRIBERIDJSON);        
    Test.stopTest();
    System.assertNotEquals(res, null);
  } 

  static TestMethod void test_cancelPush(){
    CalloutMock mock = CalloutMock.simpleSuccess(MockResponse.emptyjson);    
    Test.setMock(HttpCalloutMock.class, mock);    
    Test.startTest();
    PackageController.RestResult res = PackageController.CancelPush(PKGID, 'NOREQUEST');    
    Test.stopTest();
    System.assertNotEquals(res, null);  
  } 

  static TestMethod void test_getPendingJobs(){
    CalloutMock mock = CalloutMock.simpleSuccess(MockResponse.emptyjson);    
    Test.setMock(HttpCalloutMock.class, mock);    
    Test.startTest();
    String res = PackageController.getPendingJobs(PKGID);    
    Test.stopTest();
    System.assertNotEquals(res, null);  
  } 

  static TestMethod void test_getFromPkgOrgPackageVersions(){
    CalloutMock mock = CalloutMock.simpleSuccess(MockResponse.emptyjson);    
    Test.setMock(HttpCalloutMock.class, mock);    
    Test.startTest();
    String res = PackageController.getFromPkgOrgPackageVersions(PKGID, PKGVERID);    
    Test.stopTest();
    System.assertNotEquals(res, null);  
  } 

  static TestMethod void test_getPkgOrgDetails(){
    CalloutMock mock = CalloutMock.simpleSuccess(MockResponse.emptyjson);    
    Test.setMock(HttpCalloutMock.class, mock);    
    Test.startTest();
    String res = PackageController.getPkgOrgDetails(PKGID, SUBSCRIBERID);    
    Test.stopTest();
    System.assertNotEquals(res, null);  
  } 

}