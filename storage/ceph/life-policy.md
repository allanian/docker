```
<?xml version="1.0" ?>
<LifecycleConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
	<Rule>
		<ID>cd328dc7-1cad-4cbc-8e52-934b8150b4bf</ID>
		<Filter>
			<Prefix>repairs/</Prefix>
		</Filter>
		<Status>Enabled</Status>
		<Expiration>
			<Date>2019-01-01T00:00:00.000Z</Date>
		</Expiration>
	</Rule>
	<Rule>
		<ID>daf2578d-3bb0-4317-a7d6-a0d60eb5999b</ID>
		<Filter>
			<Prefix>claims/</Prefix>
		</Filter>
		<Status>Enabled</Status>
		<Expiration>
			<Date>2019-01-01T00:00:00.000Z</Date>
		</Expiration>
	</Rule>
	<Rule>
		<ID>delete-all-objects-older-date</ID>
		<Filter>
			<Prefix>defects/</Prefix>
		</Filter>
		<Status>Enabled</Status>
		<Expiration>
			<Date>2019-01-01T00:00:00.000Z</Date>
		</Expiration>
	</Rule>
</LifecycleConfiguration>


s3cmd setlifecycle lf.xml s3://web

# get LF
s3cmd getlifecycle s3://web
# upload
s3cmd setlifecycle lf.xml s3://web
# info
s3cmd info s3://web
```
