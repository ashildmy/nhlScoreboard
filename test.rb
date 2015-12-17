require 'terminal-notifier'

puts 1
# TerminalNotifier.notify('Hello World')
puts 2
TerminalNotifier.notify('Hello World', :title => 'Ruby', :subtitle => 'Programming Language')
puts 3
TerminalNotifier.notify('Hello World', :activate => 'com.apple.Safari')
puts 4
TerminalNotifier.notify('Hello World', :open => 'http://twitter.com/alloy')
puts 5
TerminalNotifier.notify('Hello World', :execute => 'say "OMG"')
puts 6
TerminalNotifier.notify('Hello World', :group => Process.pid)
puts 7
TerminalNotifier.notify('Hello World', :sender => 'com.apple.Safari')
puts 8
TerminalNotifier.notify('Hello World', :sound => 'default')
