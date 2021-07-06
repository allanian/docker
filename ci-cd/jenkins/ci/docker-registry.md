# Использование докер образа из личного регистри
```
    docker.withRegistry('https://private-registry-1', 'credentials-1') {
        image = docker.image('my-image:tag')
        image.pull()
    }

```
