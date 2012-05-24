#Setup
if ARGV.length < 3
  $stderr.puts "Wrong number of arguments\nUsage: genWave.rb numSamples samplesPerCycle offset wave"
  exit
end

numSamples = ARGV[0].to_i
samplesPerCycle = ARGV[1].to_i
offset = ARGV[2].to_i
wave = ARGV[3].downcase unless ARGV[3].nil?

#Make some data
data = []
numSamples.times do
  |i|
  t = Math::PI*i/samplesPerCycle
  if wave == "sawtooth" then
    data.push (2*(t-t.floor + offset) - 1)
  elsif wave == "triangle" then
    data.push ((t-2*((t+1)/2).floor)*(-1)**(((t+1)/2).floor))
  else
    data.push Math.sin(t + offset)
  end
end

#Post process into the correct waveform if needed
if wave == "square" then
  data.map!{|x| (x>=0) ? 1 : 0;}
end

#Output
data.each{|x| puts x}
