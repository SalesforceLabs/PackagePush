@IsTest
private class PackagePush_Tests {

public static final String PKGID = '0331U000000Eif5QAC';

@testSetup static void setup() {

  System.debug('PackagePush_Tests setup called');

  sfLma__Package__c p = new sfLma__Package__c();
  p.sfLma__Package_ID__c = PKGID;
  insert p;

  sfLma__Package_Version__c v = new sfLma__Package_Version__c();
  v.sfLma__Package__c = PKGID;
  insert v;

  PackageNcMapping__c nc = new PackageNcMapping__c();
  //nc.Name = 'nc1';
  nc.IsActive__c = true;
  nc.NamedCredential__c = 'nc1';
  nc.RelatedPackage__c = p.Id;
  insert nc;
}

static TestMethod void test_getNC(){
  String nc = PackageController.getNC(PKGID);
  System.assertNotEquals(nc, null);
}

static TestMethod void test_getPackages(){
  sfLma__Package__c[] res = PackageController.getPackages();
  System.assertNotEquals(res, null);
}

/*
  //public static RestResult schedulePush(String pkgid, String packageverid, String starttime, String orgs) 
  static TestMethod void test_getPackageVersions(){
    CalloutMock mock = CalloutMock.simpleSuccess(PackageVersionsResponse_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    Test.setMock(HttpCalloutMock.class, mock);
    PackageVersionResponse pvr;
    Test.startTest();
    pvr = api.getPackageVersions('1234');
    Test.stopTest();
    Log.debug(pvr.records);
    System.assertNotEquals(pvr, null);
  }

  static testMethod void test_getInstallablePackagesWithVersions(){
    CalloutMock mock = CalloutMock.simpleSuccess(InstallablePackagesWithVersions_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    Test.setMock(HttpCalloutMock.class, mock);
    InstallablePackagesWithVersions ipwv;
    Test.startTest();
    ipwv = api.getInstallablePackagesWithVersions();
    Test.stopTest();
    Log.debug(ipwv);
    System.assertNotEquals(ipwv, null);
  }

  static testMethod void test_getInstallablePackages(){
    CalloutMock mock = CalloutMock.simpleSuccess(InstallablePackagesWithVersions_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    Test.setMock(HttpCalloutMock.class, mock);
    InstallablePackages ipwv;
    Test.startTest();
    ipwv = api.getInstallablePackages();
    Test.stopTest();
    Log.debug(ipwv);
    System.assertNotEquals(ipwv, null);
  }

  static testMethod void test_installablePackagesWithVersions(){
    CalloutMock mock = CalloutMock.simpleSuccess(InstallablePackagesWithVersions_Test.json);
    sfLma__Package__c pkg = (sfLma__Package__c) TestFactory.createSObject(new sfLma__Package__c(sflma__Developer_Org_ID__C='00D6A0000002p1kUAA', sflma__Package_ID__c='0336A000000CnbmQAC'), true);
    sfLma__Package_Version__c pkgver = (sfLma__Package_Version__c) TestFactory.createSObject(new sfLma__Package_Version__c(sflma__package__c=pkg.id, sflma__Version_ID__c='04t6A000000ENilQAG'), true);
    sfLma__License__c license = (sfLma__License__c) TestFactory.createSObject(new sfLma__License__c(sflma__package__c=pkg.id, sflma__Package_Version__c=pkgver.id, sflma__Subscriber_org_Id__c='00D6A0000003kIp'), true);
    Test.setMock(HttpCalloutMock.class, mock);
    InstallablePackagesWithVersions ipwv;
    Test.startTest();
    ipwv = PackagePushAPIWrapper.getPackageVersionsOfLicense(license.id);
    test.stopTest();
    system.assertNotEquals(ipwv, null);
  }

  static testMethod void test_installablePackagesWithVersionsAPI(){
    CalloutMock mock = CalloutMock.simpleSuccess(InstallablePackagesWithVersions_Test.json);
    Test.setMock(HttpCalloutMock.class, mock);
    InstallablePackagesWithVersions ipwv;
    Test.startTest();
    ipwv = PackagePushAPIWrapper.getInstallablePackagesWithVersionsApi();
    test.stopTest();
    system.assertNotEquals(ipwv, null);
  }


  static testMethod void test_getStringOfPackageVersion(){
    CalloutMock mock = CalloutMock.simpleSuccess(PackageVersionsResponse_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    test.setMock(HttpCalloutMock.class, mock);
    String result;
    test.startTest();
    result = api.getStringOfPackageVersion('04t6A000000ENilQAG');
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  static testMethod void test_getStringOfPackagesWithVersionForPackage(){
    CalloutMock mock = CalloutMock.simpleSuccess(PackageVersionsResponse_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    test.setMock(HttpCalloutMock.class, mock);
    InstallablePackagesWithVersions.MetadataPackageVersions ipwv = PackagePushAPIResponses.parsePackageVersionsResp(InstallablePackagesWithVersions_Test.json);
    String result;
    test.startTest();
    result = api.getStringOfPackagesWithVersionsForPackage('04t6A000000ENilQAG', ipwv);
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  Static testMethod void test_getScheduledPushUpgradesWithOrgs(){
    CalloutMock mock = CalloutMock.simpleSuccess(ScheduledPushUpgrades_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    test.setMock(HttpCalloutMock.class, mock);
    getScheduledPushUpgradesWithOrgs.GetScheduledPushUpgradesWOrgs result;
    test.startTest();
    result = api.getScheduledPushUpgradesWithOrgs();
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  Static testMethod void test_getScheduledPushUpgradesAPI(){
    CalloutMock mock = CalloutMock.simpleSuccess(ScheduledPushUpgrades_Test.json);
    test.setMock(HttpCalloutMock.class, mock);
    getScheduledPushUpgradesWithOrgs.GetScheduledPushUpgradesWOrgs result;
    test.startTest();
    result = PackagePushAPIWrapper.getScheduledPushUpgradesWithOrgsApi();
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  Static testMethod void test_getScheduledPushUpgrades(){
    CalloutMock mock = CalloutMock.simpleSuccess(ScheduledPushUpgrades_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    test.setMock(HttpCalloutMock.class, mock);
    ScheduledPushUpgradesData result;
    test.startTest();
    result = api.getScheduledPushUpgrades();
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  static testMethod void test_getInstalledVersionsWithsubscribers(){
    CalloutMock mock = CalloutMock.simpleSuccess(InstalledVersionsWithSubscribers_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    test.setMock(HttpCalloutMock.class, mock);
    InstalledVersionsWithSubscribers ivws;
    test.startTest();
    ivws = api.getInstalledVersionsWithSubscribers();
    test.stopTest();
    system.assertNotEquals(ivws, null);
  }

  static testMethod void test_getInstalledVersionsWithsubscribersWithScope(){
    CalloutMock mock = CalloutMock.simpleSuccess(InstalledVersionsWithSubscribers_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    test.setMock(HttpCalloutMock.class, mock);
    String ivws;
    test.startTest();
    ivws = api.getStringInstalledVersionsWithSubscribers(new List<String>{'00D6A0000002p1kUAA'});
    test.stopTest();
    system.assertNotEquals(ivws, null);
  }

  static testMethod void test_createPushUpgradeRecord(){
    CalloutMock mock = CalloutMock.simpleSuccess(CreatePushUpgradeRecord_Test.json);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    test.setMock(HttpCalloutMock.class, mock);
    String packageId = '0336A000000CnbmQAC';
    DateTime updateAt = DateTime.now().addYears(1);
    CreatePushUpgradeRecord cpur;
    test.startTest();
    cpur = api.createPushUpgradeRecord(packageId, updateAt);
    test.stopTest();
    system.assertNotEquals(cpur, null);
  }

  static testMethod void test_createPushUpgradeRecordBadResult(){
    CalloutMock mock = CalloutMock.simpleSuccess(CreatePushUpgradeRecord_Test.badJson);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    test.setMock(HttpCalloutMock.class, mock);
    String packageId = '0336A000000CnbmQAC';
    DateTime updateAt = DateTime.now().addYears(1);
    CreatePushUpgradeRecord cpur;
    Boolean didCatchException = false;
    test.startTest();
    try{
      cpur = api.createPushUpgradeRecord(packageId, updateAt);
    } catch(PackagePushAPIWrapper.PackagePushAPIWrapperException ppawe){
      didCatchException = true;
    }
    test.stopTest();
    system.assert(didCatchException);
  }

  static testMethod void test_addOrgsToPushUpgradeResponseStatic(){
    CalloutMock mock = CalloutMock.simpleSuccess(CreatePushUpgradeRecord_Test.json);
    test.setMock(HttpCalloutMock.class, mock);
    String packageId = '0336A000000CnbmQAC';
    String orgId = '00D6A0000002p1kUAA';
    DateTime updateAt = DateTime.now().addYears(1);
    AddOrgsToPushUpgradeResponse pur;
    test.startTest();
    pur = PackagePushAPIWrapper.schedulePushUpgradesForOrgsApi(packageId, orgId, updateAt);
    test.stopTest();
    system.assertNotEquals(pur, null);
  }

  static testMethod void test_cancelPackagePushRequest(){
    CalloutMock mock = CalloutMock.simpleSuccess('{"success":true"}');
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    test.setMock(HttpCalloutMock.class, mock);
    String result;
    test.startTest();
    result = api.cancelPackagePushRequest('00D6A0000002p1kUAA'); // this id is bogus, but works for testing
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  static testMethod void test_cancelPackagePushRequestApi(){
    CalloutMock mock = CalloutMock.simpleSuccess('{"success":true"}');
    test.setMock(HttpCalloutMock.class, mock);
    String result;
    test.startTest();
    result = PackagePushAPIWrapper.cancelPackagePushRequestApi('00D6A0000002p1kUAA'); // this id is bogus, but works for testing
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  static testMethod void test_staticQuery(){
    CalloutMock mock = CalloutMock.simpleSuccess('{"success":true"}');
    test.setMock(HttpCalloutMock.class, mock);
    String result;
    test.startTest();
    result = PackagePushAPIWrapper.query('testing', 'select id from account');
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  static testMethod void test_staticCreate(){
    CalloutMock mock = CalloutMock.simpleSuccess('{"success":true"}');
    test.setMock(HttpCalloutMock.class, mock);
    String result;
    test.startTest();
    result = PackagePushAPIWrapper.create('testing', 'Account', '{"lastName":"foobar"}');
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  static testMethod void test_staticTreeCreate(){
    CalloutMock mock = CalloutMock.simpleSuccess('{"success":true"}');
    test.setMock(HttpCalloutMock.class, mock);
    String result;
    test.startTest();
    result = PackagePushAPIWrapper.treeCreate('testing', 'Account', '{"lastName":"foobar"}');
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  static testMethod void test_staticPatch(){
    CalloutMock mock = CalloutMock.simpleSuccess('{"success":true"}');
    test.setMock(HttpCalloutMock.class, mock);
    String result;
    test.startTest();
    result = PackagePushAPIWrapper.patch('testing', 'Account', '00D6A0000002p1kUAA', '{"lastName":"foobar"}');
    test.stopTest();
    system.assertNotEquals(result, null);
  }

  static testMethod void test_generatePacakgeAndSubscriberData(){
    Map<Integer,CalloutMock> requests = new Map<Integer,CalloutMock>();
    requests.put(0, CalloutMock.simpleSuccess(InstallablePackagesWithVersions_Test.json));
    requests.put(1, CalloutMock.simpleSuccess(InstalledVersionsWithSubscribers_Test.json));
    CalloutMock mocks = new CalloutMock(requests);
    test.setMock(HttpCalloutMock.class, mocks);
    PackagePushAPIWrapper api = new PackagePushAPIWrapper('testing');
    PackagePushAPIInnerClasses.PackageAndSubscriberData data;
    Test.startTest();
    data = api.generatePackageAndSubscriberData();
    Test.stopTest();
    System.assertNotEquals(data, null);
  }
*/

}