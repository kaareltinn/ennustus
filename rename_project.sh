# tested on macOS 10.12.4
# based on https://elixirforum.com/t/how-to-change-a-phoenix-project-name-smoothly/1217/6

# replace values as necessary
current_otp="foobar"
current_name="Foobar"
new_otp="ennustus"
new_name="Ennustus"

git grep -l $current_otp | xargs sed -i '' -e 's/'$current_otp'/'$new_otp'/g'
git grep -l $current_name | xargs sed -i '' -e 's/'$current_name'/'$new_name'/g'
mv ./lib/$current_otp ./lib/$new_otp
mv ./lib/foobar_web .lib/ennustus_web
mv ./lib/$current_otp.ex ./lib/$new_otp.ex
