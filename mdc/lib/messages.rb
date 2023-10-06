require 'yaml'

$messages = YAML.load_file("#{File.dirname(__FILE__)}/messages.yml")
$language = 'en'

public

##
# Translate the given key with the default language
# @param [Symbol|String] key the key
# @return the translated text
def translate(key)
  $messages[$language][key.to_s]
end

##
# Set the language to be used
# @param [String] language the language
def set_language(language)
  $language = language
end
