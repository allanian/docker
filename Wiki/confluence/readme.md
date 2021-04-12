#### find page with specific symbol and rename it
```
we have page with name - [infra] test
go to confluence postgres database and query pageID
SELECT CONTENTID FROM content WHERE TITLE = '[infra] test';
47317255
https://confluence.company.ru/pages/viewpage.action?pageId=47317255
```
