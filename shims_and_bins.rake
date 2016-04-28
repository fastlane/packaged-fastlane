# Fastlane
desc "Copy the fastlane shim into #{DESTROOT}."
file "#{DESTROOT}/fastlane" do
  cp 'shims/fastlane_shim', "#{DESTROOT}/fastlane"
end

desc "Copy the installable fastlane shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/fastlane"  do
  cp 'bins/fastlane_bin', "#{FULL_BUNDLE_PATH}/fastlane"
end

# Sigh
desc "Copy the sigh shim into #{DESTROOT}."
file "#{DESTROOT}/sigh" do
  cp 'shims/sigh_shim', "#{DESTROOT}/sigh"
end

desc "Copy the installable sigh shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/sigh"  do
  cp 'bins/sigh_bin', "#{FULL_BUNDLE_PATH}/sigh"
end

# Snapshot
desc "Copy the snapshot shim into #{DESTROOT}."
file "#{DESTROOT}/snapshot" do
  cp 'shims/snapshot_shim', "#{DESTROOT}/snapshot"
end

desc "Copy the installable snapshot shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/snapshot"  do
  cp 'bins/snapshot_bin', "#{FULL_BUNDLE_PATH}/snapshot"
end

# PEM
desc "Copy the pem shim into #{DESTROOT}."
file "#{DESTROOT}/pem" do
  cp 'shims/pem_shim', "#{DESTROOT}/pem"
end

desc "Copy the installable pem shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/pem"  do
  cp 'bins/pem_bin', "#{FULL_BUNDLE_PATH}/pem"
end

# FrameIt
desc "Copy the frameit shim into #{DESTROOT}."
file "#{DESTROOT}/frameit" do
  cp 'shims/frameit_shim', "#{DESTROOT}/frameit"
end

desc "Copy the installable frameit shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/frameit"  do
  cp 'bins/frameit_bin', "#{FULL_BUNDLE_PATH}/frameit"
end

# Deliver
desc "Copy the deliver shim into #{DESTROOT}."
file "#{DESTROOT}/deliver" do
  cp 'shims/deliver_shim', "#{DESTROOT}/deliver"
end

desc "Copy the installable deliver shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/deliver"  do
  cp 'bins/deliver_bin', "#{FULL_BUNDLE_PATH}/deliver"
end

# Produce
desc "Copy the produce shim into #{DESTROOT}."
file "#{DESTROOT}/produce" do
  cp 'shims/produce_shim', "#{DESTROOT}/produce"
end

desc "Copy the installable produce shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/produce"  do
  cp 'bins/produce_bin', "#{FULL_BUNDLE_PATH}/produce"
end

# Gym
desc "Copy the gym shim into #{DESTROOT}."
file "#{DESTROOT}/gym" do
  cp 'shims/gym_shim', "#{DESTROOT}/gym"
end

desc "Copy the installable gym shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/gym"  do
  cp 'bins/gym_bin', "#{FULL_BUNDLE_PATH}/gym"
end

# Scan
desc "Copy the scan shim into #{DESTROOT}."
file "#{DESTROOT}/scan" do
  cp 'shims/scan_shim', "#{DESTROOT}/scan"
end

desc "Copy the installable scan shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/scan"  do
  cp 'bins/scan_bin', "#{FULL_BUNDLE_PATH}/scan"
end

# Match
desc "Copy the match shim into #{DESTROOT}."
file "#{DESTROOT}/match" do
  cp 'shims/match_shim', "#{DESTROOT}/match"
end

desc "Copy the installable match shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/match"  do
  cp 'bins/match_bin', "#{FULL_BUNDLE_PATH}/match"
end

# Cert
desc "Copy the cert shim into #{DESTROOT}."
file "#{DESTROOT}/cert" do
  cp 'shims/cert_shim', "#{DESTROOT}/cert"
end

desc "Copy the installable cert shim into the root of the bundle."
file "#{FULL_BUNDLE_PATH}/cert"  do
  cp 'bins/cert_bin', "#{FULL_BUNDLE_PATH}/cert"
end
