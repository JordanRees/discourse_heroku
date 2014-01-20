mandrill_file = Rails.root.join('config', 'mandrill.yml')
mandrill_username = ENV['MANDRILL_USERNAME']
mandrill_password = ENV['MANDRILL_PASSWORD']

if File.exists?(mandrill_file) && mandrill = YAML.load_file(mandrill_file)
  ENV['MANDRILL_USERNAME'] = mandrill['username']
  ENV['MANDRILL_PASSWORD'] = mandrill['password']
end
