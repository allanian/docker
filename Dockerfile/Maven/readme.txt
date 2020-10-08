For push pkg to gitlab package registry
1) in each service add pom.txt (repositories and distributionManagement)
2) add ci_settings.xml with token for auth
3) do mvn deploy
