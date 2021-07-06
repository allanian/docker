```
Отлов ошибок
    try {
        stage('Вытягиваем изменения') {
            checkout scm
            gitLib = load "git_push_ssh"
        }
    } catch (e) {
        currentBuild.result = "FAILED"
        echo "Build failed with following exception:"
        e.printStackTrace()
        throw e
    } finally {
        sendEmails()
    }

```
