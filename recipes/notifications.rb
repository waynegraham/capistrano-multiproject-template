namespace :deploy do

  task :migrate do
    # nothing
  end

  task :finalize_update, :except => { :no_release => true } do
    run "rm -rf #{latest_release}/application/logs"
    run "ln -snf #{shared_path}/logs #{latest_release}/application/logs"
  end

  def drawAscii
    some_text = <<END_OF_STRING

  #{application} Deployinated
           \\
             ____
          .-'    '-.
         /.|      | \\
        // :-.--.-:`\\|
        ||| `.\\/.' |||
        || `-'\\/'-' ||
   .--. ||  .'  '.  || .--.
  /   .: \\\/ .--. \\// :.    \\
 |  .'  | \\  '--'  / |  `.  |
  \\ '-'/'. `-.__.-' .'\\`-' /
   '--: /\\  _|  |_  /\\ :--'
       `\\ '/      \\\' /'
         '.        .'
          :.______.:
          '.      .'
           : .--. :
           | |  | |
           L_|  |_J
          J  |  |  L
         /___|  |___\\

END_OF_STRING
  end

  task :art do
    puts drawAscii
  end

  after "deploy", "deploy:cleanup", "deploy:art"

end
