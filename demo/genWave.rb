if ARGV.length < 3
  $stderr.puts "Wrong number of arguments\nUsage: genWave.rb numSamples samplesPerCycle offset"
  exit
end

numSamples = ARGV[0].to_i
samplesPerCycle = ARGV[1].to_i
offset = ARGV[2].to_i

numSamples.times do
  |i|
  puts Math.sin(Math::PI*i/samplesPerCycle + offset)
end
