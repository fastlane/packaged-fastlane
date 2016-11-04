env_string = `gem env`
dirty_paths = env_string.split("GEM PATHS:\n")[1].split("\n  - GEM CONFIGURATION:\n")[0].split("\n")

paths = dirty_paths.map { |p| p[7..-1] }

puts paths.join(":")
