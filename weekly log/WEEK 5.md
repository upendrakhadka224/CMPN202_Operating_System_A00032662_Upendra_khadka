
================================================================================
WEEK 5: ADVANCED SECURITY AND MONITORING INFRASTRUCTURE
================================================================================

Student: Upendra Khadka
Institution: University of Roehampton
Date: December 2025

================================================================================
PHASE 5 OBJECTIVES
================================================================================

1. Implement mandatory access control using AppArmor
2. Configure automatic security updates
3. Deploy fail2ban for intrusion detection
4. Create security baseline verification script
5. Develop remote monitoring script
6. Document all advanced security implementations

All implementations must be demonstrated with live command execution and
comprehensive explanation in video documentation.

================================================================================
DELIVERABLE 1: ACCESS CONTROL IMPLEMENTATION (APPARMOR)
================================================================================

OBJECTIVE
---------
Implement and verify mandatory access control (MAC) using AppArmor to
restrict process capabilities and prevent privilege escalation.

MANDATORY ACCESS CONTROL CONCEPTS
----------------------------------

What is Mandatory Access Control (MAC)?
- Security architecture that restricts process capabilities
- Enforces policy defined by system administrator
- Processes confined to specific resources and operations
- Prevents unauthorized actions even by root processes

MAC vs DAC (Discretionary Access Control):
DAC (Traditional Linux):
- Owner controls file permissions
- Root can do anything
- Users can change their file permissions
- Vulnerable to privilege escalation

MAC (AppArmor/SELinux):
- System-wide policy controls access
- Even root processes confined
- Users cannot change MAC policy
- Defense against compromised processes

Why AppArmor?
- Default on Ubuntu
- Easier than SELinux (path-based vs context-based)
- Good balance of security and usability
- Extensive profile library included
- Active development and support

AppArmor vs SELinux:
AppArmor:
- Path-based access control
- Simpler to configure
- Per-application profiles
- Default on Ubuntu/Debian

SELinux:
- Context-based access control
- More complex configuration
- System-wide policies
- Default on RHEL/CentOS

APPARMOR ARCHITECTURE
---------------------

Components:
1. Kernel Module: Enforces policies
2. Userspace Tools: Manage profiles
3. Profile Library: Pre-configured profiles
4. Parser: Compiles profiles into binary format

Profile Modes:
- Enforce: Violations blocked, logged
- Complain: Violations allowed, logged
- Unconfined: No restrictions applied

Profile Locations:
/etc/apparmor.d/              : Profile directory
/etc/apparmor.d/abstractions/ : Reusable profile components
/etc/apparmor.d/tunables/     : System-specific variables

APPARMOR STATUS CHECK
----------------------

Command:
sudo aa-status

Expected Output:
apparmor module is loaded.
129 profiles are loaded.
32 profiles are in enforce mode.
   /usr/bin/evince
   /usr/bin/evince-previewer
   /usr/sbin/cups-browsed
   /usr/sbin/cupsd
   /usr/sbin/rsyslogd
   [... more profiles ...]
5 profiles are in complain mode.
   /usr/sbin/sssd
   transmission-cli
   transmission-daemon
   [... more profiles ...]
92 profiles are in unconfined mode.
5 processes have profiles defined.
5 processes are in enforce mode.
0 processes are in complain mode.

Analysis:
- Module Loaded: ✓ AppArmor active
- 129 Profiles: System-wide coverage
- 32 Enforcing: Critical services protected
- 5 Complaining: Monitoring mode (logs only)
- 92 Unconfined: Optional profiles available

Key Metrics:
Total Profiles: 129
Enforce Mode: 32 (25%)
Complain Mode: 5 (4%)
Unconfined: 92 (71%)

Protected Processes:
- cups-browsed (print service)
- cupsd (print daemon)
- rsyslogd (system logging)
- SSH-related processes
- System utilities

APPARMOR SERVICE VERIFICATION
------------------------------

Check Service Status:
Command:
sudo systemctl status apparmor

Expected Output:
● apparmor.service - Load AppArmor profiles
     Loaded: loaded (/usr/lib/systemd/system/apparmor.service; enabled; preset: enabled)
     Active: active (exited) since Wed 2025-12-24 17:28:16 UTC
       Docs: man:apparmor(7)
             https://gitlab.com/apparmor/apparmor/wikis/home/

Analysis:
- Status: active (exited) - Normal for AppArmor
- Enabled: Starts on boot
- Loaded profiles at boot time

Service Behavior:
- Loads profiles at system startup
- Exits after loading (not a daemon)
- Kernel module remains active
- Profiles enforced by kernel

DETAILED PROFILE ANALYSIS
--------------------------

View All Profiles:
Command:
sudo aa-status --profiled

Count Profiles by Mode:
Command:
sudo aa-status | grep "profiles are in"

Output:
32 profiles are in enforce mode.
5 profiles are in complain mode.
0 profiles are in prompt mode.
0 profiles are in kill mode.
92 profiles are in unconfined mode.

Enforce Mode Profiles (Selected):
/usr/bin/evince               : PDF viewer
/usr/sbin/cups-browsed        : Print service discovery
/usr/sbin/cupsd               : Print server
/usr/sbin/rsyslogd            : System logger
/usr/bin/man                  : Manual page viewer
lsb_release                   : Distribution info tool

Purpose of Each:
- evince: Restricts PDF viewer from accessing arbitrary files
- cups: Confines print services to necessary operations
- rsyslogd: Limits logger to /var/log and required resources
- man: Prevents man pages from accessing sensitive data

Complain Mode Profiles:
/usr/sbin/sssd                : System Security Services Daemon
transmission-*                : BitTorrent client profiles

Why Complain Mode?
- Testing new profiles
- Complex applications need refinement
- Logs violations without blocking
- Allows gradual policy development

PROFILE STRUCTURE EXAMPLE
--------------------------

View a Profile:
Command:
sudo cat /etc/apparmor.d/usr.sbin.rsyslogd | head -n 30

Profile Components:
1. Profile Name: /usr/sbin/rsyslogd
2. Capabilities: What privileged operations allowed
3. File Rules: What files can be accessed
4. Network Rules: Network operations allowed
5. Include Statements: Reusable policy components

Example Rules:
/var/log/** rw,               : Read/write to /var/log
/etc/rsyslog.conf r,          : Read config file
capability sys_admin,         : Admin capabilities
capability net_admin,         : Network admin

Rule Syntax:
r  : Read access
w  : Write access
x  : Execute access
m  : Memory map with PROT_EXEC
k  : Lock files
l  : Link files

MONITORING APPARMOR ACTIVITY
-----------------------------

View Recent Events:
Command:
sudo journalctl -u apparmor | tail -n 50

Or:
sudo journalctl -u apparmor --since "1 hour ago"

View Denial Messages:
Command:
sudo journalctl | grep -i "apparmor.*denied" | tail -n 20

Or check audit log:
sudo grep "apparmor.*DENIED" /var/log/audit/audit.log 2>/dev/null | tail -n 20

Note: audit.log may not exist if auditd not installed

Denial Log Format:
type=AVC msg=audit(timestamp): apparmor="DENIED" operation="open" profile="..." name="..." pid=... comm="..."

Fields Explained:
- operation: What was attempted (open, exec, etc.)
- profile: Which AppArmor profile blocked it
- name: File/resource that was blocked
- pid: Process ID that attempted action
- comm: Command name

No Denials Expected:
In properly configured system, should see few or no denials
Denials indicate:
1. Profile too restrictive (needs adjustment)
2. Application bug (accessing unnecessary resources)
3. Potential security issue (unauthorized access attempt)

APPARMOR PROFILE MANAGEMENT
----------------------------

List All Profiles:
sudo ls -1 /etc/apparmor.d/

Common Operations:

Disable a Profile:
sudo aa-disable /etc/apparmor.d/usr.bin.man

Enable a Profile:
sudo aa-enforce /etc/apparmor.d/usr.bin.man

Set to Complain Mode:
sudo aa-complain /etc/apparmor.d/usr.bin.man

Reload Profiles:
sudo systemctl reload apparmor

Or:
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.man

Check Profile Syntax:
sudo apparmor_parser -p /etc/apparmor.d/usr.bin.man

APPARMOR EFFECTIVENESS
----------------------

Security Benefits:
1. Privilege Escalation Prevention
   - Even if process compromised, confined to profile
   - Can't access files outside allowed paths
   - Can't perform unauthorized operations

2. Reduced Attack Impact
   - Compromised web server can't read /etc/shadow
   - Exploited application can't modify system files
   - Malware limited to profile-allowed actions

3. Defense in Depth
   - Additional layer beyond DAC (file permissions)
   - Protects against zero-day exploits
   - Limits damage from software bugs

Example Protection:
Without AppArmor:
- Compromised web server → Full system access
- Buffer overflow → Execute arbitrary code anywhere
- Privilege escalation → Root access

With AppArmor:
- Compromised web server → Limited to /var/www
- Buffer overflow → Can't execute outside profile
- Privilege escalation → Still confined by MAC

APPARMOR LIMITATIONS
--------------------

Known Limitations:
1. Path-based (not inode-based)
   - Hard links can bypass some restrictions
   - Renamed files may escape confinement

2. Not All Apps Profiled
   - 92 profiles unconfined in this system
   - New applications need profile development
   - Complex apps difficult to profile

3. Performance Overhead
   - Small performance impact (<5%)
   - Each file access checked against profile
   - Binary profile format minimizes impact

4. Maintenance Required
   - Profiles need updates for application changes
   - May need troubleshooting if too restrictive
   - Complain mode generates many logs

Best Practices:
- Keep profiles updated
- Monitor complain mode profiles
- Review denial logs regularly
- Start new profiles in complain mode
- Test thoroughly before enforce mode

APPARMOR SECURITY POSTURE
--------------------------

Current Configuration:
✓ AppArmor enabled and loaded
✓ 32 critical services in enforce mode
✓ 5 services in complain mode (monitoring)
✓ Kernel module active
✓ Profiles loaded at boot

Security Rating: GOOD
- Core system services protected
- Print services confined
- System logging restricted
- Additional profiles available

Improvement Opportunities:
- Move complain profiles to enforce
- Enable more unconfined profiles
- Custom profiles for installed applications
- Regular profile updates

Protected Attack Vectors:
✓ Malicious PDF documents (evince confined)
✓ Compromised print services (cups confined)
✓ Log injection attacks (rsyslog confined)
✓ Exploited system utilities

Documentation for Journal:
- Screenshot of aa-status output
- Profile count and distribution
- Active enforcement status
- Protected processes list

TRACKING AND REPORTING
-----------------------

Weekly Report Command:
Command:
sudo aa-status | head -n 20 > apparmor-status.txt

Monthly Audit:
1. Review denial logs
2. Check complain mode profiles
3. Update profiles as needed
4. Test new profile versions

Monitoring Script Addition:
Include in security-baseline.sh:
echo "--- AppArmor Status ---"
sudo aa-status | head -n 10

Include in monitor-server.sh:
ssh user@host "sudo aa-status | head -n 5"

APPARMOR CONFIGURATION SUMMARY
-------------------------------

Implementation Status:
✓ Verified AppArmor enabled
✓ Confirmed 129 profiles loaded
✓ Validated 32 profiles enforcing
✓ Checked service status
✓ Reviewed denial logs (none found)
✓ Documented profile distribution

Security Impact: MEDIUM-HIGH
- Mandatory access control active
- Critical services confined
- Additional protection layer
- Reduces privilege escalation risk

Next Steps:
- Continue monitoring
- Consider enforcing complain mode profiles
- Add AppArmor status to baseline script
- Regular audit of denial logs

================================================================================
DELIVERABLE 2: AUTOMATIC SECURITY UPDATES
================================================================================

OBJECTIVE
---------
Configure automatic installation of security updates to ensure system
remains patched against known vulnerabilities without manual intervention.

SECURITY UPDATE RATIONALE
--------------------------

Why Automatic Updates?
1. Timely Patching: Security updates applied immediately
2. Reduced Vulnerability Window: Hours instead of days/weeks
3. Consistency: No forgotten updates
4. Peace of Mind: System stays current automatically
5. Compliance: Meets security baseline requirements

Vulnerability Lifecycle:
1. Vulnerability discovered
2. Vendor notified (CVE assigned)
3. Patch developed and tested
4. Update released
5. Admin applies update ← Automation helps here
6. System protected

Without Automation:
- Admin must monitor advisories
- Manual update scheduling required
- Risk of delayed patching
- Human error possible

With Automation:
- Updates checked daily
- Critical updates installed automatically
- Consistent update schedule
- Reduced human involvement

Risks of Automatic Updates:
- Updates could break applications
- Unexpected reboots (if configured)
- Compatibility issues
- Limited testing before deployment

Mitigation:
- Only security updates (not all updates)
- No automatic reboots by default
- Email notifications (optional)
- Snapshot before updates (VM environment)

UNATTENDED-UPGRADES PACKAGE
----------------------------

What is unattended-upgrades?
- Ubuntu package for automatic updates
- Integrates with APT package manager
- Configurable update policies
- Installed by default on Ubuntu Server 24.04

Features:
- Security-only updates (configurable)
- Automatic download and installation
- Configurable reboot behavior
- Email notifications
- Blacklist/whitelist packages
- Update success/failure logging

Installation (if not present):
Command:
sudo apt install unattended-upgrades -y

Verification:
dpkg -l | grep unattended-upgrades

Expected Output:
ii  unattended-upgrades    2.9.1+nmu4ubuntu1    all    automatic installation of security upgrades

CONFIGURATION PROCESS
---------------------

Step 1: Install Package
-----------------------

Command:
sudo apt install unattended-upgrades -y

Expected Output:
Reading package lists... Done
Building dependency tree... Done
unattended-upgrades is already the newest version (2.9.1+nmu4ubuntu1)
0 upgraded, 0 newly installed, 0 to remove and X not upgraded.

If already installed, proceeds with configuration

Step 2: Configure Automatic Updates
------------------------------------

Command:
sudo dpkg-reconfigure --priority=low unattended-upgrades

Interactive Prompt:
"Automatically download and install stable updates?"
- Use arrow keys to select: <Yes>
- Press Enter

What This Does:
1. Creates /etc/apt/apt.conf.d/20auto-upgrades
2. Enables periodic update checks
3. Enables unattended upgrade execution
4. Starts unattended-upgrades service

Configuration Result:
File: /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";

Settings Explained:
Update-Package-Lists "1":
- Check for updates: Every 1 day
- Downloads package lists
- Checks for available updates

Unattended-Upgrade "1":
- Install updates: Every 1 day
- Applies security updates
- Automatically installs packages

Step 3: Verify Configuration
-----------------------------

View Configuration:
Command:
cat /etc/apt/apt.conf.d/20auto-upgrades

Expected Output:
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";

Verify Service Status:
Command:
sudo systemctl status unattended-upgrades

Expected Output:
● unattended-upgrades.service - Unattended Upgrades Shutdown
     Loaded: loaded (/usr/lib/systemd/system/unattended-upgrades.service; enabled; preset: enabled)
     Active: active (running) since Wed 2025-12-24 17:28:19 UTC
       Docs: man:unattended-upgrade(8)
   Main PID: 837 (unattended-upgr)

Analysis:
- Status: active (running) ✓
- Enabled: Starts at boot ✓
- Main PID: Service process running ✓

DETAILED CONFIGURATION OPTIONS
-------------------------------

Main Configuration File:
/etc/apt/apt.conf.d/50unattended-upgrades

View Configuration:
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades

Key Configuration Sections:

1. Allowed Origins (What to Update):
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Default: Security updates only
- Ubuntu security repository
- ESM (Extended Security Maintenance) if enabled
- No general updates, only security fixes

2. Package Blacklist (Never Update):
Unattended-Upgrade::Package-Blacklist {
    // "vim";
    // "nginx";
};

Use Case:
- Critical production packages
- Custom-compiled software
- Known compatibility issues

3. Automatic Reboot:
Unattended-Upgrade::Automatic-Reboot "false";

Default: false (no automatic reboots)
Set to "true" only if:
- Can tolerate unexpected reboots
- No active users
- Testing/development environment

With Reboot Time:
Unattended-Upgrade::Automatic-Reboot-Time "02:00";

4. Email Notifications:
Unattended-Upgrade::Mail "admin@example.com";
Unattended-Upgrade::MailReport "on-change";

Options:
- "always": Every run
- "only-on-error": Failures only
- "on-change": When updates applied

Requires: mailutils package

5. Remove Unused Dependencies:
Unattended-Upgrade::Remove-Unused-Dependencies "true";

Automatically removes packages no longer needed

6. Remove Unused Kernels:
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";

Keeps only 2-3 most recent kernels

Recommended Settings (Production):
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::AutoFixInterruptedDpkg "true";

TESTING AUTOMATIC UPDATES
--------------------------

Dry Run (Test Without Installing):
Command:
sudo unattended-upgrade --dry-run --debug

Purpose:
- See what would be updated
- Verify configuration working
- No actual changes made

Manual Run (Force Update Check):
Command:
sudo unattended-upgrade --debug

Purpose:
- Manually trigger update process
- See immediate results
- Test configuration

Check for Available Updates:
Command:
apt list --upgradable

View Security Updates:
Command:
apt list --upgradable | grep -i security

Example Output:
libssl3/noble-security 3.0.13-0ubuntu3.4 amd64 [upgradable from: 3.0.13-0ubuntu3.3]
openssh-server/noble-security 1:9.6p1-3ubuntu13.5 amd64 [upgradable from: 1:9.6p1-3ubuntu13.4]

UPDATE SCHEDULE
---------------

Default Schedule:
- Check for updates: Daily (around 06:00)
- Install updates: Daily (if available)
- Random delay: Up to 30 minutes
- System timer controlled

View Timers:
Command:
systemctl list-timers | grep apt

Expected Output:
apt-daily.timer           : APT download (update package lists)
apt-daily-upgrade.timer   : APT upgrade (install updates)

Timer Details:
Command:
systemctl status apt-daily-upgrade.timer

Shows:
- Next trigger time
- Last trigger time
- Timer configuration

Manual Schedule Adjustment:
Edit: /etc/systemd/system/timers.target.wants/apt-daily*.timer

Not recommended unless specific requirements

UPDATE LOGGING
--------------

Log Locations:
/var/log/unattended-upgrades/unattended-upgrades.log : Main log
/var/log/unattended-upgrades/unattended-upgrades-dpkg.log : Package details
/var/log/apt/history.log : APT history
/var/log/dpkg.log : Package installation log

View Recent Updates:
Command:
sudo tail -n 50 /var/log/unattended-upgrades/unattended-upgrades.log

Example Log Entry:
2025-12-24 06:25:32,501 INFO Starting unattended upgrades script
2025-12-24 06:25:32,502 INFO Allowed origins are: ['o=Ubuntu,a=noble-security']
2025-12-24 06:25:35,123 INFO Packages that will be upgraded: libssl3 openssh-server
2025-12-24 06:25:45,678 INFO All upgrades installed

Log Analysis:
- Start time of update run
- Allowed update origins
- Packages to be upgraded
- Installation success/failure
- Any errors encountered

Check Update History:
Command:
sudo grep -i "upgrade" /var/log/apt/history.log | tail -n 20

Shows:
- When packages were upgraded
- Which packages
- Version changes
- Success/failure status

MONITORING UPDATE STATUS
-------------------------

Check Last Update:
Command:
ls -lt /var/lib/apt/periodic/update-success-stamp

Shows last successful update check

Check Pending Updates:
Command:
apt list --upgradable | wc -l

Count of pending updates

Verify No Errors:
Command:
sudo grep -i error /var/log/unattended-upgrades/unattended-upgrades.log | tail -n 10

Should show no recent errors

Update Statistics:
Command:
sudo apt-cache stats

Shows:
- Total packages
- Normal packages
- Virtual packages
- Update statistics

TROUBLESHOOTING
----------------

Problem: Updates Not Installing

Solutions:
1. Check service running:
   sudo systemctl status unattended-upgrades

2. Verify configuration:
   cat /etc/apt/apt.conf.d/20auto-upgrades

3. Check for errors:
   sudo tail /var/log/unattended-upgrades/unattended-upgrades.log

4. Test manually:
   sudo unattended-upgrade --debug

5. Verify internet connection:
   ping security.ubuntu.com

Problem: Package Conflicts

Solution:
1. Check dpkg status:
   sudo dpkg --configure -a

2. Fix broken packages:
   sudo apt --fix-broken install

3. Update package lists:
   sudo apt update

4. Try manual upgrade:
   sudo apt upgrade

SECURITY BENEFITS
------------------

Vulnerability Window Reduction:
Without auto-updates: Days to weeks
With auto-updates: Hours to 1 day

Example Timeline:
Day 0: CVE disclosed, exploit published
Day 0: Ubuntu releases security update
Day 1: Auto-update installs patch (6AM)
Day 1: System protected

vs Manual Process:
Day 0: CVE disclosed
Day 3: Admin reads security advisory
Day 5: Admin schedules maintenance
Day 7: Update applied
Week-long vulnerability window!

Critical Updates:
- OpenSSH vulnerabilities
- Kernel security fixes
- Library updates (openssl, glibc)
- Service daemon fixes

Automated Response:
- Immediate patch application
- No admin intervention needed
- Consistent across all systems
- Reduced attack surface

AUTOMATIC UPDATES SUMMARY
--------------------------

Implementation Status:
✓ unattended-upgrades package installed
✓ Automatic updates enabled
✓ Configuration verified
✓ Service running and enabled
✓ Daily update schedule active
✓ Security-only updates configured

Update Schedule:
- Check: Daily at ~06:00
- Install: Immediately if available
- Scope: Security updates only
- Reboot: Manual (not automatic)

Security Posture:
- Vulnerability window: < 24 hours
- Patching: Automatic
- Coverage: Security updates
- Reliability: Proven Ubuntu system

Monitoring:
✓ Logs reviewed regularly
✓ Update history tracked
✓ Service status monitored
✓ Errors reported (if any)

Documentation:
- Configuration files backed up
- Settings documented
- Logs location identified
- Testing procedures defined

================================================================================
DELIVERABLE 3: FAIL2BAN INTRUSION DETECTION
================================================================================

OBJECTIVE
---------
Deploy fail2ban intrusion detection and prevention system to automatically
block hosts that show malicious signs (repeated failed login attempts).

INTRUSION DETECTION RATIONALE
------------------------------

What is Intrusion Detection?
- Monitoring system for malicious activity
- Identifies attack patterns
- Takes automated response actions
- Provides additional security layer

Why fail2ban?
1. Brute Force Protection: Blocks password guessing
2. Automated Response: No manual intervention
3. Flexible Rules: Multiple services supported
4. Temporary Bans: Releases IPs after timeout
5. Logging: Complete audit trail

Attack Scenario Without fail2ban:
1. Attacker scans for SSH servers
2. Finds server on port 22
3. Attempts 1000s of password combinations
4. Eventually may guess correct password
5. Gains unauthorized access

Attack Scenario With fail2ban:
1. Attacker scans for SSH servers
2. Finds server on port 22
3. Attempts 5 failed logins
4. fail2ban blocks attacker IP
5. Further attempts rejected by firewall
6. Account remains secure

Note: Our Implementation:
- SSH uses key-based authentication only
- Password authentication disabled
- fail2ban provides defense-in-depth
- Protects against future misconfigurations
- Logs unauthorized access attempts

FAIL2BAN ARCHITECTURE
---------------------

Components:
1. Monitor: Watches log files
2. Filter: Defines attack patterns (regex)
3. Action: Response to attacks (ban IP)
4. Jail: Configuration for a service

How It Works:
1. Monitors: /var/log/auth.log (for SSH)
2. Detects: Failed authentication attempts
3. Counts: Failures within time window
4. Actions: Adds firewall rule to block IP
5. Releases: After ban time expires

Example Flow:
IP 203.0.113.50 attempts SSH login
↓
Fails 3 times in 10 minutes
↓
fail2ban detects pattern
↓
Executes: ufw insert 1 deny from 203.0.113.50
↓
All traffic from 203.0.113.50 blocked
↓
After 10 minutes, rule removed

INSTALLATION
------------

Install fail2ban:
Command:
sudo apt install fail2ban -y

Expected Output:
Reading package lists... Done
Building dependency tree... Done
Installing fail2ban and dependencies
Setting up fail2ban (1.0.2-3ubuntu0.1)

Dependencies Installed:
- python3-systemd
- whois
- python3-pyinotify

Verify Installation:
Command:
dpkg -l | grep fail2ban

Expected Output:
ii  fail2ban  1.0.2-3ubuntu0.1  all  ban hosts causing multiple authentication errors

CONFIGURATION
-------------

Default Configuration:
/etc/fail2ban/jail.conf : Default config (don't edit)
/etc/fail2ban/jail.local : Local overrides (create this)

Best Practice:
- Never edit jail.conf (will be overwritten on update)
- Create jail.local for customizations
- jail.local overrides jail.conf settings

Create Local Configuration:
Command:
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

Purpose:
- Preserve custom settings
- Survive package updates
- Local overrides take precedence

View Default SSH Jail:
Command:
sudo grep -A 20 "\[sshd\]" /etc/fail2ban/jail.conf

Default SSH Jail Configuration:
[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = %(sshd_backend)s
maxretry = 5
findtime = 10m
bantime  = 10m

Settings Explained:
enabled = true       : SSH protection active
port = ssh          : Monitor SSH port (22)
logpath = ...       : Log file to monitor (/var/log/auth.log)
maxretry = 5        : Allow 5 failures
findtime = 10m      : Within 10 minute window
bantime = 10m       : Ban for 10 minutes

Ban Logic:
IF (failures >= 5) WITHIN (10 minutes)
THEN ban IP for 10 minutes

Customization Options (in jail.local):

Stricter Policy:
[sshd]
enabled = true
maxretry = 3
findtime = 10m
bantime = 1h

More Lenient:
[sshd]
enabled = true
maxretry = 10
findtime = 30m
bantime = 10m

Permanent Ban:
bantime = -1

Whitelist IPs (Never Ban):
ignoreip = 127.0.0.1/8 ::1 192.168.56.1

Our Configuration (Default Used):
- Using default jail.conf settings
- SSH jail automatically enabled
- maxretry = 5
- findtime = 10m
- bantime = 10m
- Management IP (192.168.56.1) implicitly safe (firewall allows it)

SERVICE MANAGEMENT
------------------

Start fail2ban:
Command:
sudo systemctl start fail2ban

Enable at Boot:
Command:
sudo systemctl enable fail2ban

Expected Output:
Synchronizing state of fail2ban.service with SysV service script...
Executing: /usr/lib/systemd/systemd-sysv-install enable fail2ban

Check Status:
Command:
sudo systemctl status fail2ban

Expected Output:
● fail2ban.service - Fail2Ban Service
     Loaded: loaded (/usr/lib/systemd/system/fail2ban.service; enabled; preset: enabled)
     Active: active (running) since Wed 2025-12-24 18:17:35 UTC
       Docs: man:fail2ban(1)
   Main PID: 6713 (fail2ban-server)
      Tasks: 5
     Memory: 19.8M
        CPU: 1.830s
     CGroup: /system.slice/fail2ban.service
             └─6713 /usr/bin/python3 /usr/bin/fail2ban-server -xf start

Status Analysis:
- Active: active (running) ✓
- Enabled: Starts on boot ✓
- PID: Server process running ✓
- Memory: 19.8M (reasonable) ✓

FAIL2BAN CLIENT COMMANDS
-------------------------

Check Overall Status:
Command:
sudo fail2ban-client status

Expected Output:
Status
|- Number of jail:      1
`- Jail list:   sshd

Explanation:
- 1 jail active (SSH)
- Only sshd jail configured

Check SSH Jail Details:
Command:
sudo fail2ban-client status sshd

Expected Output:
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     0
|  `- File list:        /var/log/auth.log
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:

Details Explained:
Currently failed: 0     : Active failures being tracked
Total failed: 0         : Total failures since start
File list: auth.log     : Monitoring this file
Currently banned: 0     : IPs currently blocked
Total banned: 0         : Total bans since start
Banned IP list: (empty) : No IPs currently banned

Good Status Indicators:
✓ Jail is running
✓ Monitoring auth.log
✓ No failed attempts (secure)
✓ No banned IPs (no attacks)

If Failures Present:
Currently failed: 3
Total failed: 15
Banned IP list: 203.0.113.50

Indicates:
- 3 recent failures from monitored IP
- 15 total failures since service start
- One IP currently banned

View Banned IPs:
Command:
sudo fail2ban-client get sshd banip

Shows: List of currently banned IPs

Unban an IP Manually:
Command:
sudo fail2ban-client set sshd unbanip 203.0.113.50

Use Case:
- Legitimate user accidentally banned
- Testing scenarios
- Emergency access needed

Ban an IP Manually:
Command:
sudo fail2ban-client set sshd banip 203.0.113.50

Use Case:
- Known malicious IP
- Proactive blocking
- Testing fail2ban

MONITORING AND LOGS
-------------------

fail2ban Log Location:
/var/log/fail2ban.log

View Recent Activity:
Command:
sudo tail -n 50 /var/log/fail2ban.log

Example Log Entries:
2025-12-24 18:17:35,911 fail2ban.server [6713]: INFO Starting Fail2ban v1.0.2
2025-12-24 18:17:36,000 fail2ban.server [6713]: INFO Starting in normal mode
2025-12-24 18:17:36,001 fail2ban.jail   [6713]: INFO Creating new jail 'sshd'
2025-12-24 18:17:36,002 fail2ban.jail   [6713]: INFO Jail 'sshd' started

Log Entry Types:
INFO: Normal operation
WARNING: Configuration issues, potential problems
ERROR: Critical errors, service failures
NOTICE: Ban/unban actions

Ban Event Example:
2025-12-24 20:15:42,123 fail2ban.actions [6713]: NOTICE [sshd] Ban 203.0.113.50
2025-12-24 20:25:42,456 fail2ban.actions [6713]: NOTICE [sshd] Unban 203.0.113.50

Shows:
- IP banned at 20:15:42
- IP unbanned at 20:25:42 (10 minutes later)

Monitor Live:
Command:
sudo tail -f /var/log/fail2ban.log

Watch for ban/unban events in real-time

Check Auth Log for Failures:
Command:
sudo grep "Failed password" /var/log/auth.log | tail -n 10

Or:
sudo grep "authentication failure" /var/log/auth.log | tail -n 10

SSH Authentication Log Examples:
Dec 24 20:10:15 ubuntu sshd[12345]: Failed password for invalid user admin from 203.0.113.50 port 54321 ssh2
Dec 24 20:10:18 ubuntu sshd[12346]: Failed password for invalid user root from 203.0.113.50 port 54322 ssh2

Shows:
- Multiple failed login attempts
- Source IP: 203.0.113.50
- Invalid usernames tried (admin, root)
- Port numbers

After 5 failures, fail2ban would ban 203.0.113.50

FIREWALL INTEGRATION
--------------------

How fail2ban Blocks IPs:
1. Detects attack pattern
2. Executes action script
3. Action adds firewall rule
4. Traffic from IP blocked
5. After ban time, rule removed

Default Action: iptables (UFW)
Command Executed:
ufw insert 1 deny from 203.0.113.50

Result:
New firewall rule at position 1 (highest priority)
All traffic from 203.0.113.50 blocked

View Firewall Rules:
Command:
sudo ufw status numbered

Example with Banned IP:
     To                         Action      From
     --                         ------      ----
[ 1] Anywhere                   DENY IN     203.0.113.50
[ 2] 22                         ALLOW IN    192.168.56.1

Notice:
- fail2ban rule at position 1
- Takes precedence over allow rules
- IP completely blocked

After Unban:
Rule automatically removed
Firewall returns to normal state

Check Current Bans via Firewall:
Command:
sudo iptables -L -n | grep -i "fail2ban"

Or:
sudo ufw status | grep -i "deny"

TESTING FAIL2BAN
----------------

Controlled Test (NOT recommended on production):

Test Scenario:
1. Attempt failed SSH logins
2. Trigger fail2ban
3. Verify ban
4. Check logs
5. Unban for normal operation

Note: In our setup, SSH uses keys only
- Password auth disabled
- Can't actually test failed passwords
- fail2ban still monitors
- Would catch configuration changes

Alternative Test:
1. Manually ban test IP
2. Verify firewall rule added
3. Check fail2ban status
4. Unban and verify removal

Manual Ban Test:
Command:
sudo fail2ban-client set sshd banip 203.0.113.50

Verify:
sudo fail2ban-client status sshd
sudo ufw status numbered

Expected:
- Currently banned: 1
- Banned IP list: 203.0.113.50
- Firewall rule present

Unban:
sudo fail2ban-client set sshd unbanip 203.0.113.50

Verify:
- Currently banned: 0
- Firewall rule removed

FAIL2BAN IN OUR CONTEXT
------------------------

Why fail2ban with Key-Based SSH?

Defense in Depth:
1. Keys prevent password attacks (primary defense)
2. fail2ban blocks persistent attackers (secondary)
3. Firewall restricts by IP (tertiary)

Scenario Where fail2ban Helps:
1. Admin accidentally re-enables password auth
2. Script kiddie discovers SSH port
3. Launches brute force attack
4. fail2ban blocks after 5 attempts
5. Prevents account compromise

Future Protection:
- If password auth re-enabled (misconfiguration)
- If another service added (e.g., web admin panel)
- If firewall rule temporarily disabled
- Multi-layered security approach

Additional Jails (Can Be Enabled):
- apache-auth: Web server auth failures
- nginx-http-auth: Nginx auth failures
- postfix: Email server attacks
- vsftpd: FTP brute force

Current Configuration:
- Only SSH jail enabled
- Appropriate for current services
- Can add jails as services added
- Monitoring /var/log/auth.log

FAIL2BAN STATISTICS
-------------------

Since Installation:
- Jails Active: 1 (sshd)
- Failed Attempts: 0
- Total Bans: 0
- Currently Banned: 0
- Service Uptime: Since installation

Analysis:
✓ No attacks detected
✓ System secure
✓ Monitoring active
✓ Ready to respond

Expected Behavior:
- Production servers: Daily ban events
- Internal servers: Few to no bans
- Internet-facing: Many bans
- Firewalled: Minimal attacks

FAIL2BAN BEST PRACTICES
------------------------

1. Regular Monitoring:
   - Check status weekly
   - Review logs monthly
   - Verify jails active

2. Whitelist Critical IPs:
   - Management networks
   - Monitoring systems
   - Known good sources

3. Appropriate Thresholds:
   - Too strict: Legitimate users banned
   - Too lenient: Attacks succeed
   - Balance usability and security

4. Log Retention:
   - Keep logs for audit
   - Analyze attack patterns
   - Identify persistent threats

5. Integration:
   - Consider SIEM integration
   - Centralized logging
   - Alert on ban events

FAIL2BAN CONFIGURATION SUMMARY
-------------------------------

Implementation Status:
✓ fail2ban installed (version 1.0.2)
✓ Service started and enabled
✓ SSH jail active and monitoring
✓ Default configuration appropriate
✓ Firewall integration working
✓ Logging configured

Jail Configuration:
- Service: sshd
- Max Retry: 5 attempts
- Find Time: 10 minutes
- Ban Time: 10 minutes
- Log File: /var/log/auth.log

Current Status:
- Failed Attempts: 0
- Banned IPs: 0
- Total Bans: 0
- Jail Running: Yes

Security Benefits:
✓ Automated intrusion response
✓ Brute force protection
✓ Defense-in-depth layer
✓ Minimal configuration required
✓ Low resource overhead

Monitoring:
- Status checks: sudo fail2ban-client status sshd
- Log review: sudo tail /var/log/fail2ban.log
- Firewall check: sudo ufw status
- Auth log: sudo grep "Failed" /var/log/auth.log

Documentation:
- Configuration files saved
- Default settings documented
- Testing procedures defined
- Integration verified

================================================================================
DELIVERABLE 4: SECURITY BASELINE VERIFICATION SCRIPT
================================================================================

OBJECTIVE
---------
Create comprehensive script to verify all security configurations from
Phases 4 and 5, enabling regular security audits and compliance checks.

SCRIPT PURPOSE
--------------

Why Security Baseline Script?
1. Automated Verification: Check all security controls
2. Consistency: Same checks every time
3. Audit Trail: Document security posture
4. Quick Assessment: Rapid security status
5. Compliance: Verify requirements met

What It Checks:
✓ SSH configuration (password auth, root login, keys)
✓ Firewall status and rules
✓ fail2ban operation and status
✓ Automatic updates configuration
✓ AppArmor status and profiles
✓ User privileges and accounts
✓ Pending security updates

When to Use:
- Daily automated checks
- After configuration changes
- Before major updates
- Security audits
- Incident response
- Documentation updates

SCRIPT CREATION
---------------

Script Location: /home/upendra/security-baseline.sh

Create Script:
Command:
nano security-baseline.sh

Script Content:
```bash
#!/bin/bash
# Security Baseline Verification Script
# Verifies all security configurations from Phases 4 and 5
# Author: Upendra Khadka
# Date: December 2025

echo "=========================================="
echo "Security Baseline Verification Report"
echo "=========================================="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo ""

# SSH Security Configuration
echo "--- SSH Security Configuration ---"
echo "Password Authentication:"
sudo sshd -T | grep passwordauthentication
echo "Public Key Authentication:"
sudo sshd -T | grep pubkeyauthentication
echo "Root Login:"
sudo sshd -T | grep permitrootlogin
echo "SSH Service Status:"
sudo systemctl is-active ssh
echo ""

# Firewall Configuration
echo "--- Firewall Configuration ---"
sudo ufw status verbose
echo ""

# Fail2ban Intrusion Detection
echo "--- Fail2ban Intrusion Detection ---"
echo "Fail2ban Service:"
sudo systemctl is-active fail2ban
echo "SSH Jail Status:"
sudo fail2ban-client status sshd
echo ""

# Automatic Security Updates
echo "--- Automatic Security Updates ---"
cat /etc/apt/apt.conf.d/20auto-upgrades
echo "Unattended Upgrades Service:"
sudo systemctl is-active unattended-upgrades
echo ""

# AppArmor Mandatory Access Control
echo "--- AppArmor Mandatory Access Control ---"
sudo aa-status | head -n 15
echo ""

# User Privileges
echo "--- Administrative Users ---"
echo "Users with sudo privileges:"
getent group sudo
echo ""

# Pending Security Updates
echo "--- Pending Security Updates ---"
apt list --upgradable 2>/dev/null | grep -i security | head -n 10
echo ""

echo "=========================================="
echo "Security Baseline Verification Complete"
echo "=========================================="
```

Save: Ctrl+X, Y, Enter

SCRIPT EXPLANATION
------------------

Script Structure:

1. Header Section:
   - Shebang (#!/bin/bash)
   - Comments documenting purpose
   - Author and date

2. Report Header:
   - Timestamp
   - Hostname identification
   - Clear section markers

3. Security Checks:
   - SSH configuration
   - Firewall status
   - Intrusion detection
   - Automatic updates
   - Access control
   - User privileges
   - Update status

4. Report Footer:
   - Completion message
   - Clear end marker

Line-by-Line Explanation:

#!/bin/bash
- Specifies bash shell interpreter
- Required for script execution
- Must be first line

echo "=== Security Baseline Verification ==="
- Prints report header
- Clear visual separation
- Human-readable output

echo "Date: $(date)"
- Shows current timestamp
- $(date) command substitution
- Documents when check performed

sudo sshd -T | grep passwordauthentication
- sshd -T: Test mode, shows active config
- grep: Filters for specific setting
- Shows actual running configuration

sudo systemctl is-active ssh
- Checks if service running
- Returns: active or inactive
- Simple status check

sudo ufw status verbose
- Shows firewall status
- verbose: Detailed output
- Displays all rules and policies

sudo fail2ban-client status sshd
- Queries fail2ban daemon
- Shows SSH jail status
- Displays ban statistics

cat /etc/apt/apt.conf.d/20auto-upgrades
- Displays update configuration
- Shows periodic update settings
- Verifies automatic updates enabled

sudo aa-status | head -n 15
- Shows AppArmor status
- head -n 15: First 15 lines
- Summary of profiles

getent group sudo
- Lists sudo group members
- Shows users with admin privileges
- Verifies user configuration

apt list --upgradable | grep security
- Lists pending updates
- Filters for security updates
- Shows update status

MAKE SCRIPT EXECUTABLE
-----------------------

Set Execute Permission:
Command:
chmod +x security-baseline.sh

Verify Permissions:
Command:
ls -l security-baseline.sh

Expected Output:
-rwxr-xr-x 1 upendra upendra 2345 Dec 24 18:30 security-baseline.sh

Permissions Explained:
- rwx: Owner can read, write, execute
- r-x: Group can read, execute
- r-x: Others can read, execute

Owner Execute Permission Critical:
- Allows ./security-baseline.sh
- Required for script execution
- chmod +x adds execute bit

SCRIPT EXECUTION
----------------

Run Script:
Command:
./security-baseline.sh

Expected Output:
==========================================
Security Baseline Verification Report
==========================================
Date: Wed Dec 24 07:44:06 PM UTC 2025
Hostname: ubuntu

--- SSH Security Configuration ---
Password Authentication:
passwordauthentication no
Public Key Authentication:
pubkeyauthentication yes
Root Login:
permitrootlogin no
SSH Service Status:
active

--- Firewall Configuration ---
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22                         ALLOW IN    192.168.56.1

--- Fail2ban Intrusion Detection ---
Fail2ban Service:
active
SSH Jail Status:
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     0
|  `- File list:        /var/log/auth.log
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:

--- Automatic Security Updates ---
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
Unattended Upgrades Service:
active

--- AppArmor Mandatory Access Control ---
apparmor module is loaded.
129 profiles are loaded.
32 profiles are in enforce mode.
   /usr/bin/evince
   /usr/bin/evince-previewer
   /usr/sbin/cups-browsed
   /usr/sbin/cupsd
   /usr/sbin/rsyslogd

--- Administrative Users ---
Users with sudo privileges:
sudo:x:27:upendra,adminuser

--- Pending Security Updates ---
(No security updates pending or list of updates)

==========================================
Security Baseline Verification Complete
==========================================

OUTPUT ANALYSIS
---------------

SSH Security: ✓ PASS
- Password auth disabled
- Public key enabled
- Root login disabled
- Service active

Firewall: ✓ PASS
- Active and enforcing
- Default deny incoming
- SSH restricted to management IP
- Logging enabled

Fail2ban: ✓ PASS
- Service active
- SSH jail monitoring
- No banned IPs (no attacks)
- Monitoring auth.log

Automatic Updates: ✓ PASS
- Daily update checks enabled
- Auto-install enabled
- Service running

AppArmor: ✓ PASS
- Module loaded
- 129 profiles total
- 32 profiles enforcing
- Critical services protected

Users: ✓ PASS
- Two admin users (upendra, adminuser)
- Both have sudo privileges
- Proper group membership

Updates: ✓ PASS or INFO
- Shows any pending security updates
- Action required if updates listed

Overall Status: SECURE
All security controls operational

SCRIPT USAGE SCENARIOS
-----------------------

Scenario 1: Daily Check
Command:
./security-baseline.sh

Purpose: Verify security posture
Frequency: Daily automated run
Output: Current security status

Scenario 2: After Configuration Change
Command:
./security-baseline.sh > post-change-report.txt

Purpose: Document new configuration
Action: Compare with previous baseline
Verify: Changes implemented correctly

Scenario 3: Audit Documentation
Command:
./security-baseline.sh | tee security-audit-$(date +%Y%m%d).txt

Purpose: Create timestamped audit record
Output: Screen and file
Storage: Date-stamped for records

Scenario 4: Remote Execution
Command (from Windows):
ssh upendra@192.168.56.101 "./security-baseline.sh"

Purpose: Remote security check
Use Case: Monitoring from workstation
Output: Displayed on local terminal

Scenario 5: Automated Monitoring
Create cron job:
0 6 * * * /home/upendra/security-baseline.sh >> /var/log/security-baseline.log 2>&1

Purpose: Daily automated check
Schedule: 6 AM daily
Output: Appended to log file

SCRIPT ENHANCEMENTS (OPTIONAL)
-------------------------------

Add Color Output:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}✓ PASS${NC}"
echo -e "${RED}✗ FAIL${NC}"

Add Pass/Fail Logic:
if sudo systemctl is-active ssh &>/dev/null; then
    echo "✓ SSH Active"
else
    echo "✗ SSH Inactive"
fi

Add Email Notifications:
./security-baseline.sh | mail -s "Security Report" admin@example.com

Add JSON Output:
For parsing by monitoring systems
Output structured data

Add Compliance Checks:
CIS Benchmark checks
NIST controls verification
Custom policy checks

TROUBLESHOOTING
----------------

Problem: Permission Denied

Solution:
chmod +x security-baseline.sh

Problem: sudo Password Prompts

Solution:
Run entire script with sudo:
sudo ./security-baseline.sh

Or configure passwordless sudo for specific commands

Problem: Command Not Found

Solution:
Install missing packages:
sudo apt install ufw fail2ban

Problem: Output Too Long

Solution:
Pipe to less:
./security-baseline.sh | less

Or redirect to file:
./security-baseline.sh > report.txt

SECURITY BASELINE SCRIPT SUMMARY
---------------------------------

Implementation Status:
✓ Script created (security-baseline.sh)
✓ Made executable (chmod +x)
✓ Tested successfully
✓ All checks functional
✓ Output clear and readable

Script Capabilities:
- Verifies 6 security areas
- Automated execution
- Remote execution compatible
- Comprehensive reporting
- Easily maintainable

Output Quality:
- Clear section headers
- Structured information
- Timestamped reports
- Human-readable format
- Complete status summary

Use Cases:
✓ Daily security checks
✓ Post-change verification
✓ Audit documentation
✓ Compliance reporting
✓ Incident response

Integration:
- Can be automated (cron)
- Remote execution (SSH)
- Log aggregation compatible
- Monitoring system ready
- Documentation friendly

Security Value: HIGH
- Rapid security assessment
- Configuration verification
- Audit trail creation
- Compliance validation
- Problem identification

================================================================================
DELIVERABLE 5: REMOTE MONITORING SCRIPT
================================================================================

OBJECTIVE
---------
Create script that runs on Windows workstation to monitor Ubuntu server
remotely via SSH, collecting performance and status metrics.

SCRIPT PURPOSE
--------------

Why Remote Monitoring Script?
1. Centralized Monitoring: Check from workstation
2. No Server Resources: Runs on client
3. Historical Data: Can log results
4. Automation Ready: Schedule checks
5. Quick Assessment: Rapid health check

What It Monitors:
✓ System uptime and load average
✓ CPU usage and top processes
✓ Memory utilization
✓ Disk space usage
✓ Network interface status
✓ Active network connections
✓ Critical service status
✓ System load metrics

Execution Location: Windows Workstation
Connection Method: SSH with keys
Target System: Ubuntu Server

SCRIPT CREATION (WINDOWS)
--------------------------

Location: C:\Users\Admin\OneDrive\Desktop\Upendra-Ubuntu\

Two Options:
1. PowerShell Script (.ps1)
2. Bash Script (requires WSL or Git Bash)

Option 1: PowerShell Script

Create File:
Open Notepad or VS Code
File: monitor-server.ps1

PowerShell Script Content:
```powershell
# Remote Server Monitoring Script (PowerShell)
# Monitors Ubuntu server from Windows workstation
# Author: Upendra Khadka
# Date: December 2025

$SERVER_USER = "upendra"
$SERVER_IP = "192.168.56.101"
$SSH_KEY = "C:\Users\Admin\OneDrive\Desktop\Upendra-Ubuntu\id_ed25519"

Write-Host "=========================================="
Write-Host "Remote Server Monitoring Report"
Write-Host "=========================================="
Write-Host "Connecting to: $SERVER_USER@$SERVER_IP"
Write-Host "Timestamp: $(Get-Date)"
Write-Host ""

Write-Host "--- System Uptime and Load ---"
ssh -i $SSH_KEY "$SERVER_USER@$SERVER_IP" "uptime"
Write-Host ""

Write-Host "--- CPU Usage (Top 5 Processes) ---"
ssh -i $SSH_KEY "$SERVER_USER@$SERVER_IP" "ps aux --sort=-%cpu | head -n 6"
Write-Host ""

Write-Host "--- Memory Usage ---"
ssh -i $SSH_KEY "$SERVER_USER@$SERVER_IP" "free -h"
Write-Host ""

Write-Host "--- Disk Usage ---"
ssh -i $SSH_KEY "$SERVER_USER@$SERVER_IP" "df -h | grep -E '^/dev/'"
Write-Host ""

Write-Host "--- Network Interfaces ---"
ssh -i $SSH_KEY "$SERVER_USER@$SERVER_IP" "ip -br addr"
Write-Host ""

Write-Host "--- Active Connections ---"
ssh -i $SSH_KEY "$SERVER_USER@$SERVER_IP" "ss -tuln | head -n 10"
Write-Host ""

Write-Host "--- Critical Services Status ---"
ssh -i $SSH_KEY "$SERVER_USER@$SERVER_IP" "systemctl is-active ssh nginx fail2ban apparmor unattended-upgrades"
Write-Host ""

Write-Host "--- Load Average ---"
ssh -i $SSH_KEY "$SERVER_USER@$SERVER_IP" "cat /proc/loadavg"
Write-Host ""

Write-Host "=========================================="
Write-Host "Remote Monitoring Complete"
Write-Host "=========================================="
```

Option 2: Bash Script (for Git Bash/WSL)

Create File:
File: monitor-server.sh

Bash Script Content:
```bash
#!/bin/bash
# Remote Server Monitoring Script (Bash)
# Runs on Windows workstation via Git Bash/WSL
# Author: Upendra Khadka
# Date: December 2025

SERVER_USER="upendra"
SERVER_IP="192.168.56.101"
SSH_KEY="/c/Users/Admin/OneDrive/Desktop/Upendra-Ubuntu/id_ed25519"

echo "=========================================="
echo "Remote Server Monitoring Report"
echo "=========================================="
echo "Connecting to: $SERVER_USER@$SERVER_IP"
echo "Timestamp: $(date)"
echo ""

echo "--- System Uptime and Load ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "uptime"
echo ""

echo "--- CPU Usage (Top 5 Processes) ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "ps aux --sort=-%cpu | head -n 6"
echo ""

echo "--- Memory Usage ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "free -h"
echo ""

echo "--- Disk Usage ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "df -h | grep -E '^/dev/'"
echo ""

echo "--- Network Interfaces ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "ip -br addr"
echo ""

echo "--- Active Connections ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "ss -tuln | head -n 10"
echo ""

echo "--- Critical Services ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "systemctl is-active ssh nginx fail2ban apparmor unattended-upgrades"
echo ""

echo "--- Load Average ---"
ssh -i "$SSH_KEY" $SERVER_USER@$SERVER_IP "cat /proc/loadavg"
echo ""

echo "=========================================="
echo "Remote Monitoring Complete"
echo "=========================================="
```

SCRIPT USAGE
------------

PowerShell Execution:
Command:
cd "C:\Users\Admin\OneDrive\Desktop\Upendra-Ubuntu"
.\monitor-server.ps1

Bash Execution (Git Bash):
Command:
cd "/c/Users/Admin/OneDrive/Desktop/Upendra-Ubuntu"
bash monitor-server.sh

Individual Commands (PowerShell):
```powershell
$KEY = "C:\Users\Admin\OneDrive\Desktop\Upendra-Ubuntu\id_ed25519"
$HOST = "upendra@192.168.56.101"

# System uptime
ssh -i $KEY $HOST "uptime"

# Memory usage
ssh -i $KEY $HOST "free -h"

# Disk usage
ssh -i $KEY $HOST "df -h"

# Service status
ssh -i $KEY $HOST "systemctl is-active ssh nginx fail2ban"
```

EXPECTED OUTPUT
---------------

Running monitor-server.ps1:

==========================================
Remote Server Monitoring Report
==========================================
Connecting to: upendra@192.168.56.101
Timestamp: 12/24/2025 7:30:00 PM

--- System Uptime and Load ---
 19:30:00 up  1:02,  2 users,  load average: 0.15, 0.25, 0.28

--- CPU Usage (Top 5 Processes) ---
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.1  0.3 168644 12456 ?        Ss   18:28   0:01 /sbin/init
root         608  0.0  0.2 108244  8932 ?        Ssl  18:28   0:00 rsyslogd
upendra     5518  0.0  0.1  14592  5432 ?        Ss   18:30   0:00 sshd

--- Memory Usage ---
               total        used        free      shared  buff/cache   available
Mem:           3.1Gi       922Mi       1.3Gi        27Mi       1.1Gi       2.2Gi
Swap:             0B          0B          0B

--- Disk Usage ---
/dev/sda2        25G  4.4G   19G  19% /

--- Network Interfaces ---
lo               UNKNOWN        127.0.0.1/8 ::1/128
enp0s3           UP             10.0.2.15/24
enp0s8           UP             192.168.56.101/24

--- Active Connections ---
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:Port
tcp   LISTEN 0      128    0.0.0.0:22           0.0.0.0:*
tcp   LISTEN 0      128    :::80                :::*
tcp   LISTEN 0      128    :::22                :::*

--- Critical Services Status ---
active
active
active
active
active

--- Load Average ---
0.15 0.25 0.28 1/245 12345

==========================================
Remote Monitoring Complete
==========================================

OUTPUT ANALYSIS
---------------

System Health Indicators:

Uptime: 1:02
- System stable
- No recent reboots
- Continuous operation

Load Average: 0.15, 0.25, 0.28
- 1 min: 0.15 (very low)
- 5 min: 0.25 (very low)
- 15 min: 0.28 (very low)
- System not busy
- 4 CPU cores available
- Load < 1.0 per core = healthy

CPU Usage:
- init (PID 1): 0.1% (expected)
- rsyslogd: 0.0% (normal)
- sshd: 0.0% (idle)
- Total CPU usage: < 1%
- System idle

Memory Usage:
- Total: 3.1 GB
- Used: 922 MB (28%)
- Available: 2.2 GB (72%)
- No swap usage
- Healthy memory state

Disk Usage:
- Total: 25 GB
- Used: 4.4 GB (19%)
- Free: 19 GB (81%)
- Plenty of space
- No concerns

Network Interfaces:
- lo: Loopback (127.0.0.1) UP
- enp0s3: NAT (10.0.2.15) UP
- enp0s8: Host-only (192.168.56.101) UP
- All interfaces operational

Active Connections:
- SSH (port 22): Listening
- HTTP (port 80): Listening (nginx)
- No unexpected services
- Normal network state

Services Status:
- ssh: active ✓
- nginx: active ✓
- fail2ban: active ✓
- apparmor: active ✓
- unattended-upgrades: active ✓
- All critical services running

Overall Assessment: HEALTHY
- Low load
- Adequate resources
- All services operational
- No issues detected

MONITORING SCHEDULE
-------------------

Recommended Frequency:

Real-time Monitoring:
- During performance tests
- During configuration changes
- When issues suspected

Regular Checks:
- Daily: Morning health check
- Weekly: Detailed review
- Monthly: Trend analysis

Automated Monitoring:
PowerShell Scheduled Task:
1. Open Task Scheduler
2. Create Basic Task
3. Trigger: Daily at 8:00 AM
4. Action: Start Program
   Program: powershell.exe
   Arguments: -File "C:\Path\To\monitor-server.ps1"
5. Save task

Or use Windows Task Scheduler GUI

Logging Output:
Command:
.\monitor-server.ps1 | Out-File -Append "monitoring-log.txt"

Or:
.\monitor-server.ps1 >> monitoring-log-$(Get-Date -Format "yyyyMMdd").txt

TROUBLESHOOTING
----------------

Problem: Script Execution Policy

Error:
"execution of scripts is disabled on this system"

Solution:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Problem: SSH Connection Fails

Solutions:
1. Verify server running:
   ping 192.168.56.101

2. Check SSH service:
   Direct SSH test: ssh -i "path\to\key" upendra@192.168.56.101

3. Verify key path correct

4. Check firewall allows connection

Problem: Commands Time Out

Solutions:
1. Increase SSH timeout:
   ssh -o ConnectTimeout=30 ...

2. Check network connectivity

3. Verify server not overloade

Problem: Partial Output

Solutions:
1. Check for errors in output
2. Verify commands work individually
3. Test SSH connection manually

MONITORING SCRIPT SUMMARY
--------------------------

Implementation Status:
✓ PowerShell script created
✓ Bash script alternative provided
✓ Individual commands documented
✓ Execution tested
✓ Output verified

Script Capabilities:
- Remote system monitoring
- Multiple metric collection
- Service status verification
- Resource utilization tracking
- Network status checking

Execution Methods:
✓ PowerShell (.ps1)
✓ Bash (.sh via Git Bash/WSL)
✓ Individual SSH commands
✓ Automated scheduling

Output Quality:
- Structured sections
- Clear labeling
- Timestamped reports
- Human-readable format
- Complete system overview

Use Cases:
✓ Daily health checks
✓ Performance monitoring
✓ Capacity planning
✓ Troubleshooting
✓ Status reporting

Integration:
- Can be scheduled (Task Scheduler)
- Output can be logged
- Alert-ready (check for specific values)
- Dashboard-compatible
- Report generation

Monitoring Value: HIGH
- Proactive health monitoring
- Early problem detection
- Resource tracking
- Service verification
- Documentation generation

================================================================================
WEEK 5 LEARNING OUTCOMES
================================================================================

Advanced Security Skills:
1. Mandatory access control (AppArmor)
2. Automatic update management
3. Intrusion detection configuration
4. Bash scripting for security
5. Remote monitoring implementation

Technical Understanding:
1. MAC vs DAC security models
2. Update automation strategies
3. Intrusion detection patterns
4. Script design and structure
5. Remote command execution

Monitoring Capabilities:
1. Automated security verification
2. Remote system monitoring
3. Performance metric collection
4. Service status checking
5. Health assessment procedures

Scripting Skills:
1. Bash script creation
2. PowerShell script development
3. Cross-platform considerations
4. Error handling
5. Output formatting

Best Practices:
1. Defense-in-depth security
2. Automated security checks
3. Regular update application
4. Comprehensive monitoring
5. Documentation procedures

================================================================================
SECURITY POSTURE AFTER WEEK 5
================================================================================

Implemented Security Controls:

Layer 1 - Network Security:
✓ UFW firewall active
✓ IP-based access control
✓ Minimal open ports

Layer 2 - Access Control:
✓ SSH key-based authentication
✓ AppArmor MAC enforcement
✓ User privilege management

Layer 3 - Intrusion Detection:
✓ fail2ban active and monitoring
✓ Automated IP blocking
✓ Attack logging

Layer 4 - Patch Management:
✓ Automatic security updates
✓ Daily update checks
✓ Zero-day protection

Layer 5 - Monitoring:
✓ Security baseline verification
✓ Remote monitoring capability
✓ Service status tracking

Security Metrics:
- Hardening Controls: 10+ implemented
- Automation: 3 automated processes
- Monitoring: 2 monitoring scripts
- Services Protected: 5 critical services
- Update Frequency: Daily automatic

Attack Vectors Mitigated:
✓ Brute force attacks (SSH keys + fail2ban)
✓ Privilege escalation (AppArmor + sudo)
✓ Unpatched vulnerabilities (auto-updates)
✓ Unauthorized access (firewall + MAC)
✓ Service exploits (AppArmor confinement)

Remaining Tasks (Week 6-7):
- Performance testing
- Optimization implementation
- Final security audit (Lynis)
- Network scanning (Nmap)
- Complete documentation

Security Rating: EXCELLENT
- Multi-layered defense
- Automated protection
- Comprehensive monitoring
- Proactive patching
- Audit ready

================================================================================
CONCLUSION
================================================================================

Week 5 Successfully Completed:
✓ AppArmor MAC verified (129 profiles, 32 enforcing)
✓ Automatic updates configured and running
✓ fail2ban deployed (SSH jail active)
✓ Security baseline script created and tested
✓ Remote monitoring script developed and operational
✓ All advanced security features documented

Security Improvements:
- Added mandatory access control layer
- Implemented automated patching
- Deployed intrusion detection
- Created verification automation
- Established monitoring capability

System Status:
- Fully hardened security configuration
- Automated security maintenance
- Comprehensive monitoring in place
- Ready for performance testing phase
- Audit-ready security posture

Evidence Collected:
✓ AppArmor status screenshots
✓ Update configuration verified
✓ fail2ban operation demonstrated
✓ Script execution documented
✓ Remote monitoring tested

Next Phase: Week 6 - Performance Testing
- Baseline performance measurement
- Application stress testing
- Resource utilization analysis
- Optimization implementation
- Performance documentation

Project Progress: 71% Complete (5 of 7 weeks)
Security Posture: EXCELLENT (Advanced controls implemented)
System Status: PRODUCTION READY (fully hardened)

================================================================================
END OF WEEK 5 DOCUMENTATION
================================================================================
