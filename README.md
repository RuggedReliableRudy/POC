cpe-stack/
├─ terraform/
│  ├─ main.tf
│  ├─ variables.tf
│  ├─ modules/
│  │  ├─ rds/
│  │  │  └─ main.tf
│  │  └─ ec2/
│  │     └─ main.tf
├─ ansible/
│  ├─ inventory.ini
│  ├─ site.yml
│  ├─ roles/
│  │  ├─ java_app/
│  │  │  └─ tasks/main.yml
│  │  └─ db_active_active/
│  │     └─ tasks/main.yml
├─ .github/
│  └─ workflows/
│     └─ build-and-deploy.yml
├─ build.gradle
├─ settings.gradle
├─ gradlew
├─ gradlew.bat
└─ gradle/
   └─ wrapper/
      ├─ gradle-wrapper.jar
      └─ gradle-wrapper.properties

