require 'bundler/inline'

gemfile do
  source 'http://rubygems.org'
  ruby '2.4.3'
  gem 'launchy'
  gem 'pry'
  gem 'ruby-trello'
end

require 'trello'
require 'yaml'

include Trello
include Trello::Authorization

class Story < OpenStruct
  def labels
    (super || '').split(/,\s*/)
  end
end

class TrelloSlurper

  def self.slurp(filename)
    new(filename).slurp
  end

  def slurp
    configure_trello
    load_stories
    push_stories
  end

  def board
    @board ||= Board.find(ENV['TRELLO_BOARD_ID'])
  end

  def labels_for(story)
    story.labels.map do |label_string|
      board.labels.find {|x| x.name.downcase.strip == label_string.downcase.strip }
    end.compact
  end

  def list
    @list ||= List.find(ENV['TRELLO_LIST_ID'])
  end

  def initialize(filename)
    @filename = filename
  end

  def configure_trello
    Trello.configure do |config|
      config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
      config.member_token = ENV['TRELLO_MEMBER_TOKEN']
    end
  end

  def load_stories
    @stories = IO.read(@filename).
      split('==').
      map { |text| YAML.load(text) }.
      map { |hash| Story.new(hash) }
  end

  def push_stories
    @cards = @stories.map do |story|
      puts "Adding story \"#{story.name}\""
      card = Card.create({
        list_id: ENV['TRELLO_LIST_ID'],
        name: story.name,
        desc: story.description,
      })
      labels_for(story).map {|l| card.add_label(l) }
    end
  end

end

if ARGV.first.nil?
  puts "Run the following to get started:"
  puts "ruby ./trello_slurper.rb config"
  puts "Or pass a yaml file path if you've done that"
elsif ARGV.first == 'config'
  puts "Agree to the terms and copy the key, then run:"
  puts "TRELLO_DEVELOPER_PUBLIC_KEY=<that key> ruby ./trello_slurper.rb token"
  Trello.open_public_key_url
elsif ARGV.first == 'token'
  puts "Now copy the member token and use both ENV variables:"
  puts "TRELLO_DEVELOPER_PUBLIC_KEY=#{ENV['TRELLO_DEVELOPER_PUBLIC_KEY']} TRELLO_MEMBER_TOKEN=<that token> TRELLO_BOARD_ID=<board_id> TRELLO_LIST_ID=<list_id> ruby ./trello_slurper.rb your_stories.yml"
  Trello.open_authorization_url key: ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
else
  TrelloSlurper.slurp(File.join(Dir.pwd, ARGV.first))
end
