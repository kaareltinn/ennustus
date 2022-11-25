# tested on macOS 10.12.4
# based on https://elixirforum.com/t/how-to-change-a-phoenix-project-name-smoothly/1217/6

# replace values as necessary
current_otp="ennustus"
current_name="Ennustus"
current_web_name="ennustus_web"
current_web="EnnustusWeb"

new_web_name="ennustus_web"
new_web="EnnustusWeb"
new_otp="ennustus"
new_name="Ennustus"

git grep -l $current_otp | xargs sed -i '' -e 's/'$current_otp'/'$new_otp'/g'
git grep -l $current_name | xargs sed -i '' -e 's/'$current_name'/'$new_name'/g'
git grep -l $current_web_name | xargs sed -i '' -e 's/'$current_web_name'/'$new_web_name'/g'
git grep -l $current_web | xargs sed -i '' -e 's/'$current_web'/'$new_web'/g'

# mv ./lib/$current_otp ./lib/$new_otp
# mv ./lib/$current_otp.ex ./lib/$new_otp.ex
