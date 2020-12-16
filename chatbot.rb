# Downloads chatbot data.
def download_data
  system("git clone https://github.com/LWFlouisa/Chatbots.git")
end

# Removes uneeded chatbots to safe space.
def purge_data
  system("rm -rfv Chatbots")
end

# Learned data is saved in folder.
def shutdown
  puts "Exiting process..."

  sleep(0.5)

  abort
end

# Wake process
def chatbot
  def shutdown # Self contained shutdown process.
    puts "Catch you later..."

    sleep(0.5)

    # Breaks loop and returns to main process.
    break
  end

  require 'programr'

  # Identities
  bot_name = File.read("data/bot_identity/name.txt")
  usr_name = File.read("data/usr_identity/name.txt")

  brains = Dir.glob("Chatbots/*")

  robot = ProgramR::Facade.new
  robot.learn(brains)

  puts " Welcome to Bianca. This is my assistant."

  while true
    print "#{usr_name } >> "
    s = STDIN.gets.chomp

    reaction = robot.get_reaction(s)

    if reaction == ""
      # reaction.play("en")

      STDOUT.puts "#{bot_name} << I have no answer for that."
    elsif reaction == "Closing"; puts "#{bot_name} << "; shutdown
    else
      # reaction.play("en")

      STDOUT.puts "#{bot_name} << #{reaction}"
    end
  end
end

# Sleep process
def naive_bayes
  old_distribution = File.read("data/baysian/archive.txt")

  print ">> "
  strings = gets.chomp.split(" ")

  number = 0

  size_limit = strings.size.to_i

  size_limit.times do
    require "naive_bayes"

    a = NaiveBayes.load('data/baysian/language.nb') 

    b = strings[number]

    classify = a.classify(*b)

    label = classify[0]
    probability = 100 - classify[1]

    open("data/baysian/archive.txt", "w") { |f|
      f.puts "[#{label}, #{probability}]"
      f.puts old_distribution
    }

    open("output/baysian/distribution.txt", "w") { |f|
      f.puts "[#{label}, #{probability}]"
      f.puts old_distribution
    }

    number += 1
  end
end

## Switch between awake, asleep, or shutdown
require "finitemachine"

fm = FiniteMachine.new do
  initial :none

  event :none, :switch_off => :switch_on
  event :on,   :switch_on  => :switch_off
  event :off,  :switch_off => :switch_on

  # Chatbot is awake.
  on_enter(:on) { |event|
    download_data
    
    chatbot
  }

  # Chatbot is asleep.
  on_enter(:off) { |event|
    purge_data
    
    naive_bayes
  }

  # Chatbot is temporarily incompacitated.
  on_enter(:none) { |event|
    shutdown
  }
end

## Main loop
while true
  puts "The current process is: #{fm.current}"

  sleep(0.5)

  puts "The current process is: #{fm.trigger}"

  sleep(0.5)
end
