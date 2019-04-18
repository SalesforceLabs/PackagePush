### useful commands for developing in LMA org. Since LMA org is not scratch org, following commands will be useful

Git repo: https://github.com/SalesforceLabs/PackagePush

## Dev LMA org

sfdx force:auth:web:login -d

sfdx force:source:deploy --manifest /Users/kamlesh.patel/lwc/labapp/PackagePush/manifest/package.xml

sfdx force:source:deploy -m ApexClass
sfdx force:source:deploy -m LightningComponentBundle
sfdx force:apex:test:run --synchronous --classnames PackagePush_Tests

## Create lightning component

sfdx force:lightning:component:create --type lwc -n SchedulePush -d ./force-app/main/default/lwc
sfdx force:lightning:component:create --type lwc -n ScheduleHistoryList -d ./force-app/main/default/lwc
sfdx force:lightning:component:create --type lwc -n PackageNCTest -d ./force-app/main/default/lwc
