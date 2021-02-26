# rocketChat send => zabbix WebHook
in rocketchat
1) create user with admin role
2) login under that user, go to profile, create token with user id
3) create channel with name zabbix and add user zabbix to that channel
4) in rocket chat admin console create new integration - zabbix
name - zabbix
channel - #zabbix
send from user - zabbix
enable yes
click save
# in zabbix
1) Administration/media types/click import and add media type from yaml https://www.zabbix.com/ru/integrations/rocketchat
2) edit media type Rocket.Chat
rc_url - https://chat.company.ru
# paste user_id and token, what we created in rocketChat in profile zabbix user
rc_user_id - user_id_example
rc_user_token - user_token_example
rc_send_to #zabbix
rc_title_link - change {$ZABBIX.URL} to https://zabbix.company.ru  (https://zabbix.company.ru .ru/tr_events.php?triggerid={TRIGGER.ID}&eventid={EVENT.ID})

# click test
event_source 1

# check with curl
```
curl -H "X-Auth-Token: pIk4RLKKd9H69gcq-UokBbWYf3MAQQmFW5JegkwW_Tt" \
     -H "X-User-Id: Dw5Dzo97WZxwgHnEJ" \
     -H "Content-type:application/json" \
     https://chat.company.ru/api/v1/chat.postMessage \
     -d '{"channel":"#zabbix","attachments":[{"collapsed":false,"color":"#97AAB3","title":"test","title_link":"https://zabbix.company.ru/tr_events.php?triggerid=test&eventid=test","text":"test"}]}'
```
# then create zabbix user with media Rocket.Chat
send to #zabbix
group zabbix admin
permission admin

### then ACTIONS
add new action
#Conditions
	Trigger severity is greater than or equals Not classified
	# oparations
	Send message to users: zabbix (zabbix) via Rocket.Chat
