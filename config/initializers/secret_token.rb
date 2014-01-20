# We have had lots of config issues with SECRET_TOKEN to avoid this mess we are moving it to redis
#  if you feel strongly that it does not belong there use ENV['SECRET_TOKEN']
#
Discourse::Application.config.secret_token = "38cf7c475083568e69f15a26d0290af5f09f186b5f0e5c6df3d4fdeee68b06ed64a97387d936dfee4438eec1ecec9cbb6c841e016499259679ff7934453fa96a"
