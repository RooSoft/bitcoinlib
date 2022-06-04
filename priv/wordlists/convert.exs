wordlist = File.read!("english.txt")
|> String.split("\n", trim: true)

File.write!("wordlist.ex", "#{inspect wordlist, limit: :infinity}")
