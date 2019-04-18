### To extend this app clone this repo and develop in seperate dev LMA org. Do not do development/test in your main LMA org.

### Useful commands for developing in dev LMA org. Since LMA org is a regular org and not a scratch org, following commands will be useful. Also in dev LMA org, you will need to include LMA managed package.

## Development in dev LMA org

sfdx force:auth:web:login -d

sfdx force:source:deploy --manifest ~/labapp/PackagePush/manifest/package.xml

sfdx force:source:deploy -m ApexClass
sfdx force:source:deploy -m LightningComponentBundle
sfdx force:apex:test:run --synchronous --classnames PackagePush_Tests

## Commands to create lightning component

sfdx force:lightning:component:create --type lwc -n SchedulePush -d ./force-app/main/default/lwc
