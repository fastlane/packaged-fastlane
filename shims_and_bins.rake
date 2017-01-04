# Fastlane
file "#{DESTROOT}/fastlane" do
  cp 'shims/fastlane_shim', "#{DESTROOT}/fastlane"
end

file "#{FULL_BUNDLE_PATH}/fastlane"  do
  cp 'bins/fastlane_bin', "#{FULL_BUNDLE_PATH}/fastlane"
end

# Sigh
file "#{DESTROOT}/sigh" do
  cp 'shims/sigh_shim', "#{DESTROOT}/sigh"
end

file "#{FULL_BUNDLE_PATH}/sigh"  do
  cp 'bins/sigh_bin', "#{FULL_BUNDLE_PATH}/sigh"
end

# Snapshot
file "#{DESTROOT}/snapshot" do
  cp 'shims/snapshot_shim', "#{DESTROOT}/snapshot"
end

file "#{FULL_BUNDLE_PATH}/snapshot"  do
  cp 'bins/snapshot_bin', "#{FULL_BUNDLE_PATH}/snapshot"
end

# PEM
file "#{DESTROOT}/pem" do
  cp 'shims/pem_shim', "#{DESTROOT}/pem"
end

file "#{FULL_BUNDLE_PATH}/pem"  do
  cp 'bins/pem_bin', "#{FULL_BUNDLE_PATH}/pem"
end

# FrameIt
file "#{DESTROOT}/frameit" do
  cp 'shims/frameit_shim', "#{DESTROOT}/frameit"
end

file "#{FULL_BUNDLE_PATH}/frameit"  do
  cp 'bins/frameit_bin', "#{FULL_BUNDLE_PATH}/frameit"
end

# Deliver
file "#{DESTROOT}/deliver" do
  cp 'shims/deliver_shim', "#{DESTROOT}/deliver"
end

file "#{FULL_BUNDLE_PATH}/deliver"  do
  cp 'bins/deliver_bin', "#{FULL_BUNDLE_PATH}/deliver"
end

# Produce
file "#{DESTROOT}/produce" do
  cp 'shims/produce_shim', "#{DESTROOT}/produce"
end

file "#{FULL_BUNDLE_PATH}/produce"  do
  cp 'bins/produce_bin', "#{FULL_BUNDLE_PATH}/produce"
end

# Gym
file "#{DESTROOT}/gym" do
  cp 'shims/gym_shim', "#{DESTROOT}/gym"
end

file "#{FULL_BUNDLE_PATH}/gym"  do
  cp 'bins/gym_bin', "#{FULL_BUNDLE_PATH}/gym"
end

# Scan
file "#{DESTROOT}/scan" do
  cp 'shims/scan_shim', "#{DESTROOT}/scan"
end

file "#{FULL_BUNDLE_PATH}/scan"  do
  cp 'bins/scan_bin', "#{FULL_BUNDLE_PATH}/scan"
end

# Match
file "#{DESTROOT}/match" do
  cp 'shims/match_shim', "#{DESTROOT}/match"
end

file "#{FULL_BUNDLE_PATH}/match"  do
  cp 'bins/match_bin', "#{FULL_BUNDLE_PATH}/match"
end

# Cert
file "#{DESTROOT}/cert" do
  cp 'shims/cert_shim', "#{DESTROOT}/cert"
end

file "#{FULL_BUNDLE_PATH}/cert"  do
  cp 'bins/cert_bin', "#{FULL_BUNDLE_PATH}/cert"
end
