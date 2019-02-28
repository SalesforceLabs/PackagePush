## Dev LMA org

dev2@lma.push/kam123456
sfdx force:source:deploy --manifest /Users/kamlesh.patel/lwc/labapp/PackagePush/manifest/package.xml

## GIT

git remote remove origin
git remote add origin https://github.com/kamipatel/packagepush.git
git commit -a --no-verify -m "init"
git push -u origin master

## Create lightning component

sfdx force:lightning:component:create --type lwc -n SchedulePush -d ./force-app/main/default/lwc
sfdx force:lightning:component:create --type lwc -n ScheduleHistoryList -d ./force-app/main/default/lwc

git commit:
git commit -a --no-verify -m "init"
git push -u origin master
git remote add origin https://github.com/kamipatel/PackagePush
Schedule.git

Scratch org:
mylma@kam.dev
https://agility-java-5425-dev-ed.lightning.force.com/docs/component-library/bundle/lightning:button/example#lightningcomponentdemo:exampleButtonsDisabled

Data import/export
Old lma org kamipatel-5uzt@force.com/kam123456
sfdx force:auth:web:login -d -a oldlmaorg
