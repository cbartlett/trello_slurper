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

class TrelloSlurper
  # change these
  PUBLIC_KEY = ''
  SECRET = ''
  ACCESS_TOKEN_KEY = ''
  BOARD_ID = ''
  LIST_ID = ''
  LABEL_COLOR = 'orange'

  def self.slurp(filename)
    new(filename).slurp
  end

  def slurp
    configure_trello
    load_stories
    push_stories
    add_labels
  end

  def board
    @board ||= Board.find(BOARD_ID)
  end

  def list
    @list ||= List.find(LIST_ID)
  end

  def initialize(filename)
    @filename = filename
  end

  def configure_trello
    Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
    OAuthPolicy.consumer_credential = OAuthCredential.new PUBLIC_KEY, SECRET
    OAuthPolicy.token = OAuthCredential.new ACCESS_TOKEN_KEY, nil
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
        list_id: LIST_ID,
        name: story.name,
        description: story.description
      })
    end
  end

  def add_labels
    @cards.map { |card| card.add_label(LABEL_COLOR) }
  end

end

class Story
  attr_reader :name, :description

  def initialize(hash)
    @name = hash['name']
    @description = hash['description']
  end
end

TrelloSlurper.slurp(File.join(Dir.pwd, ARGV.first))
