require 'formula'

class JenkinsSwarmClient < Formula
  homepage 'https://wiki.jenkins-ci.org/display/JENKINS/Swarm+Plugin'
  version '1.16'

  url "http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/#{version}/swarm-client-#{version}-jar-with-dependencies.jar"
  sha1 '3fb69c76ff5f151580bc45646405ead31f783a7f'

  def install
    libexec.install "swarm-client-#{version}-jar-with-dependencies.jar"
    (bin/'jenkins-swarm-client-service-wrapper').write <<-EOS.undent
      #!/bin/bash
      set -e

      source #{etc}/jenkins-swarm-client/jenkins-swarm-client.conf

      OPTIONS+=(${SWARM_DESCRIPTION:+-description "$SWARM_DESCRIPTION"})
      OPTIONS+=(${SWARM_DISABLE_SSL_VERIFICATION:+-disableSslVerification})
      OPTIONS+=(${SWARM_EXECUTORS:+-executors $SWARM_EXECUTORS})
      OPTIONS+=(${SWARM_FS_ROOT:+-fsroot $SWARM_FS_ROOT})
      OPTIONS+=(${SWARM_LABELS:+-labels "$SWARM_LABELS"})
      OPTIONS+=(${SWARM_MASTER:+-master "$SWARM_MASTER"})
      OPTIONS+=(${SWARM_MODE:+-mode "$SWARM_MODE"})
      OPTIONS+=(${SWARM_NAME:+-name "$SWARM_NAME"})
      OPTIONS+=(${SWARM_PASSWORD:+-password "$SWARM_PASSWORD"})
      OPTIONS+=(${SWARM_USER_NAME:+-username "$SWARM_USER_NAME"})

      exec java -jar #{(libexec/"swarm-client-#{version}-jar-with-dependencies.jar")} "${OPTIONS[@]}"
    EOS

    bin.write_jar_script libexec/"swarm-client-#{version}-jar-with-dependencies.jar", "jenkins-swarm-client"

    (etc/'jenkins-swarm-client/jenkins-swarm-client.conf').write <<-EOS.undent
       # Description to be put on the slave
       SWARM_DESCRIPTION='Description'

       # Disables SSL verification in the HttpClient.
       SWARM_DISABLE_SSL_VERIFICATION=0

       # Number of executors
       SWARM_EXECUTORS=2

       # Directory where Jenkins places files
       # SWARM_FS_ROOT=/home/jenkins

       # Whitespace-separated list of labels to be assigned
       # for this slave. Multiple options are allowed.
       # SWARM_LABELS="label1 tag2"

       #  The complete target Jenkins URL like 'http://server
       #  :8080/jenkins'. If this option is specified,
       #  auto-discovery will be skipped
       # SWARM_MASTER="http://localhost"

       # The mode controlling how Jenkins allocates jobs to
       # slaves. Can be either 'normal' (utilize this slave
       # as much as possible) or 'exclusive' (leave this
       # machine for tied jobs only). Default is normal.
       SWARM_MODE=normal

       # Name of the slave
       # SWARM_NAME='foo'

       # The Jenkins user password
       # SWARM_PASSWORD=password

       # The Jenkins username for authentication
       # SWARM_USER_NAME=user
    EOS
  end

  def plist; <<-EOS.undent
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-/Apple/DTD PLIST 1.0/EN" "http:/www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{bin}/jenkins-swarm-client-service-wrapper</string>
          </array>
          <key>KeepAlive</key>
          <true/>
          <key>RunAtLoad</key>
          <true/>
          <key>StandardErrorPath</key>
          <string>/var/log/jenkins/org.jenkins-ci.slave.jnlp.log</string>
          <key>StandardOutPath</key>
          <string>/var/log/jenkins/org.jenkins-ci.slave.jnlp.log</string>
        </dict>
      </plist>
    EOS
  end

end
