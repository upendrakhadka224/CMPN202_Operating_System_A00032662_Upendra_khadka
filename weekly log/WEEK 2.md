cat > week2-documentation.txt << 'EOF'
================================================================================
WEEK 2: SECURITY PLANNING AND TESTING METHODOLOGY
================================================================================

Student: Upendra Khadka
Institution: University of Roehampton
Date: December 2025

================================================================================
PHASE 2 OBJECTIVES
================================================================================

1. Design comprehensive performance testing methodology
2. Create security configuration checklist
3. Develop threat model with mitigation strategies
4. Plan security baseline approach
5. Document testing and monitoring strategy

================================================================================
DELIVERABLE 1: PERFORMANCE TESTING PLAN
================================================================================

TESTING METHODOLOGY
-------------------

Monitoring Approach:
- Primary Method: Remote monitoring from Windows workstation via SSH
- Tool: Custom monitor-server.sh script
- Execution: SSH-based remote command execution
- Frequency: Continuous monitoring during test execution
- Data Collection: Real-time metrics capture

Monitoring Infrastructure:
┌─────────────────────────────────────────────────────────┐
│              Windows Workstation                         │
│         (Monitoring Control Station)                     │
│                                                          │
│  ┌────────────────────────────────────────┐            │
│  │     monitor-server.sh script           │            │
│  │  (PowerShell/Bash execution)          │            │
│  └──────────────┬─────────────────────────┘            │
└─────────────────┼──────────────────────────────────────┘
                  │
                  │ SSH Connection
                  │ (192.168.56.101:22)
                  │
┌─────────────────┴──────────────────────────────────────┐
│              Ubuntu Server                              │
│         (Target System)                                 │
│                                                         │
│  Performance Metrics:                                   │
│  - CPU usage (top, vmstat)                             │
│  - Memory usage (free, vmstat)                         │
│  - Disk I/O (iostat, df)                              │
│  - Network stats (ss, ip)                              │
│  - Process info (ps)                                    │
└─────────────────────────────────────────────────────────┘

TESTING APPROACH
----------------

Phase 1: Baseline Testing
- Objective: Establish idle system performance metrics
- Method: Measure system at rest with no load
- Duration: 5 minutes of continuous monitoring
- Metrics:
  * CPU load average
  * Memory usage (used/free/available)
  * Disk utilization percentage
  * Network interface statistics
  * System uptime and stability

Phase 2: Load Testing
- Objective: Measure performance under typical workload
- Method: Run selected applications with standard parameters
- Duration: Variable per application (30-60 seconds each)
- Metrics:
  * CPU usage percentage per core
  * Memory allocation and consumption
  * Disk I/O operations per second (IOPS)
  * Network throughput (Mbps)
  * Application response times

Phase 3: Stress Testing
- Objective: Push system resources to maximum capacity
- Method: Run intensive workloads to identify limits
- Duration: Extended tests (60-120 seconds)
- Metrics:
  * Peak CPU utilization
  * Maximum memory consumption
  * Disk I/O bottlenecks
  * Network bandwidth saturation
  * System stability under load

Phase 4: Optimization Testing
- Objective: Validate performance improvements
- Method: Re-test after applying optimizations
- Duration: Same as baseline for comparison
- Metrics:
  * Before/after performance comparison
  * Percentage improvement quantification
  * Resource utilization efficiency
  * System responsiveness

METRICS TO MONITOR
------------------

CPU Metrics:
- Overall CPU usage percentage (0-100%)
- Per-core utilization
- Load average (1min, 5min, 15min)
- Context switches per second
- CPU wait time (I/O wait)

Memory Metrics:
- Total RAM (GB)
- Used memory (MB/GB)
- Free memory (MB/GB)
- Available memory (MB/GB)
- Buffer/cache usage (MB/GB)
- Swap usage (if configured)

Disk I/O Metrics:
- Read operations per second (IOPS)
- Write operations per second (IOPS)
- Read throughput (MB/s, KiB/s)
- Write throughput (MB/s, KiB/s)
- Average latency (milliseconds)
- Disk utilization percentage

Network Metrics:
- Bandwidth (Mbits/sec, Gbits/sec)
- Throughput (MB/s)
- Packet transmission rate
- Retransmissions
- Latency (milliseconds)
- Connection count

Service Metrics:
- Requests per second (req/s)
- Response time (milliseconds)
- Concurrent connections
- Failed requests
- Transfer rate (KB/s)

TESTING ENVIRONMENT
-------------------

Server Specifications:
- Operating System: Ubuntu Server 24.04.3 LTS
- Kernel: 6.14.0-37-generic
- RAM: 3.1 GB
- Disk: 25 GB virtual disk
- CPU: 4 cores (x86_64)
- Network: Dual interface (NAT + Host-only)

Workstation:
- Operating System: Windows
- Role: Monitoring and control station
- Connection: SSH via 192.168.56.101
- Tools: PowerShell, SSH client

Network Configuration:
- Management Network: 192.168.56.0/24 (Host-only)
- Server IP: 192.168.56.101
- Workstation IP: 192.168.56.1
- Connection Method: SSH with key-based authentication

MONITORING TOOLS
----------------

Primary Tools:
- top/htop: Real-time CPU and process monitoring
- free: Memory usage tracking
- df: Disk space monitoring
- vmstat: Virtual memory statistics
- iostat: I/O statistics
- ss/netstat: Network connection monitoring
- iperf3: Network bandwidth testing
- stress-ng: System stress testing
- fio: Disk I/O performance testing
- ab (Apache Bench): Web server load testing

Custom Scripts:
- monitor-server.sh: Automated remote monitoring
- security-baseline.sh: Security verification

================================================================================
DELIVERABLE 2: SECURITY CONFIGURATION CHECKLIST
================================================================================

1. SSH HARDENING
----------------

Configuration Items:
☐ Disable password authentication
  - File: /etc/ssh/sshd_config
  - Setting: PasswordAuthentication no
  - Reason: Prevent brute force password attacks

☐ Enable key-based authentication only
  - File: /etc/ssh/sshd_config
  - Setting: PubkeyAuthentication yes
  - Reason: Cryptographic authentication more secure

☐ Disable root login via SSH
  - File: /etc/ssh/sshd_config
  - Setting: PermitRootLogin no
  - Reason: Prevent direct root access

☐ Configure SSH timeout settings
  - Setting: ClientAliveInterval 300
  - Setting: ClientAliveCountMax 2
  - Reason: Disconnect inactive sessions

☐ Enable SSH protocol 2 only
  - Default in modern SSH
  - Reason: Protocol 1 has known vulnerabilities

☐ Limit SSH access to specific users
  - Setting: AllowUsers upendra adminuser
  - Reason: Restrict who can connect

☐ Change SSH port (optional)
  - Setting: Port 22 (or custom)
  - Reason: Reduce automated attack attempts

Verification Commands:
sudo sshd -T | grep -E "passwordauthentication|pubkeyauthentication|permitrootlogin"
sudo systemctl status ssh

2. FIREWALL CONFIGURATION
-------------------------

Configuration Items:
☐ Install and enable UFW
  - Command: sudo apt install ufw
  - Command: sudo ufw enable
  - Reason: Host-based firewall protection

☐ Default deny incoming connections
  - Command: sudo ufw default deny incoming
  - Reason: Deny-by-default security posture

☐ Default allow outgoing connections
  - Command: sudo ufw default allow outgoing
  - Reason: Allow server to reach updates/services

☐ Allow SSH from workstation IP only
  - Command: sudo ufw allow from 192.168.56.1 to any port 22
  - Reason: Restrict SSH to known management IP

☐ Block all other incoming SSH attempts
  - Implicit in deny-by-default policy
  - Reason: Prevent unauthorized access attempts

☐ Document all firewall rules
  - Command: sudo ufw status numbered
  - Reason: Maintain configuration inventory

Verification Commands:
sudo ufw status verbose
sudo ufw status numbered

3. MANDATORY ACCESS CONTROL (APPARMOR)
--------------------------------------

Configuration Items:
☐ Verify AppArmor is enabled
  - Command: sudo systemctl status apparmor
  - Reason: Ensure MAC framework is active

☐ Check active profiles
  - Command: sudo aa-status
  - Reason: Verify profile enforcement

☐ Monitor AppArmor logs for violations
  - Command: sudo journalctl -u apparmor
  - Reason: Detect policy violations

☐ Document profile status for critical services
  - Services: SSH, nginx, system services
  - Reason: Ensure proper confinement

Verification Commands:
sudo aa-status
sudo aa-status | head -n 20

4. AUTOMATIC UPDATES
--------------------

Configuration Items:
☐ Install unattended-upgrades package
  - Command: sudo apt install unattended-upgrades
  - Reason: Enable automatic patching

☐ Configure automatic security updates
  - Command: sudo dpkg-reconfigure --priority=low unattended-upgrades
  - File: /etc/apt/apt.conf.d/20auto-upgrades
  - Reason: Keep system patched against vulnerabilities

☐ Set update schedule
  - Daily security updates enabled
  - Reason: Timely vulnerability remediation

☐ Enable email notifications (optional)
  - Configure if email available
  - Reason: Alert on update issues

☐ Verify automatic update status
  - Command: cat /etc/apt/apt.conf.d/20auto-upgrades
  - Reason: Confirm configuration

Verification Commands:
sudo systemctl status unattended-upgrades
cat /etc/apt/apt.conf.d/20auto-upgrades

5. USER PRIVILEGE MANAGEMENT
----------------------------

Configuration Items:
☐ Create non-root administrative user
  - Command: sudo adduser adminuser
  - Reason: Avoid using root for daily tasks

☐ Configure sudo access
  - Command: sudo usermod -aG sudo adminuser
  - Reason: Grant administrative privileges

☐ Disable root account login
  - Command: sudo passwd -l root
  - Reason: Prevent direct root login

☐ Implement password policies
  - File: /etc/login.defs
  - Settings: Password aging, complexity
  - Reason: Strong password requirements

☐ Review user permissions regularly
  - Command: getent group sudo
  - Reason: Audit administrative access

Verification Commands:
groups upendra adminuser
sudo -l -U adminuser

6. NETWORK SECURITY
-------------------

Configuration Items:
☐ Configure host-only network for SSH
  - VirtualBox: Adapter 2 (Host-only)
  - IP: 192.168.56.101
  - Reason: Isolated management network

☐ Disable unnecessary network services
  - Review: sudo ss -tulpn
  - Reason: Minimize attack surface

☐ Install and configure fail2ban
  - Command: sudo apt install fail2ban
  - Reason: Intrusion detection and prevention

☐ Monitor failed login attempts
  - File: /var/log/auth.log
  - Tool: fail2ban
  - Reason: Detect brute force attempts

☐ Document network topology
  - Diagram created in Week 1
  - Reason: Understand attack vectors

Verification Commands:
sudo fail2ban-client status sshd
sudo ss -tulpn

================================================================================
DELIVERABLE 3: THREAT MODEL
================================================================================

THREAT 1: BRUTE FORCE SSH ATTACKS
----------------------------------

Description:
Attackers attempt to gain unauthorized access to the system by systematically
trying multiple username and password combinations on the SSH service (port 22).
This is one of the most common attack vectors against internet-facing servers.

Attack Vector:
- Target: SSH service on port 22
- Method: Automated password guessing
- Tools: Hydra, Medusa, custom scripts
- Source: Internet, automated botnets

Impact Assessment:
HIGH SEVERITY

Confidentiality:
- Complete system compromise if successful
- Access to all user data and files
- Exposure of sensitive configuration

Integrity:
- Ability to modify system files
- Installation of backdoors or malware
- Manipulation of logs to hide activity

Availability:
- Resource exhaustion from repeated attempts
- Potential system compromise and shutdown
- Service disruption

Likelihood: HIGH
- SSH is commonly targeted service
- Automated scanning tools widely available
- Default port (22) frequently scanned
- Constant internet background noise

Mitigation Strategies:

Primary Defenses:
1. Disable Password Authentication
   - Implementation: PasswordAuthentication no in sshd_config
   - Effectiveness: Eliminates password guessing completely
   - Priority: CRITICAL

2. Implement Key-Based Authentication Only
   - Implementation: PubkeyAuthentication yes
   - Effectiveness: Requires cryptographic key (2048+ bit)
   - Priority: CRITICAL

3. Restrict SSH Access by IP Address
   - Implementation: UFW firewall rule (allow from 192.168.56.1 only)
   - Effectiveness: Blocks all unauthorized source IPs
   - Priority: HIGH

4. Deploy fail2ban Intrusion Detection
   - Implementation: Monitor auth.log, ban after 5 failed attempts
   - Effectiveness: Automatically blocks persistent attackers
   - Priority: HIGH

5. Disable Root Login
   - Implementation: PermitRootLogin no
   - Effectiveness: Prevents direct root compromise
   - Priority: HIGH

Secondary Defenses:
6. Change Default SSH Port (Optional)
   - Implementation: Port 2222 (or non-standard)
   - Effectiveness: Reduces automated scan attempts
   - Priority: MEDIUM

7. Implement Rate Limiting
   - Implementation: UFW limit rule
   - Effectiveness: Slows down attack attempts
   - Priority: MEDIUM

8. Monitor Authentication Logs
   - Implementation: Regular review of /var/log/auth.log
   - Effectiveness: Early detection of attack patterns
   - Priority: MEDIUM

Implementation Timeline:
- Week 4: SSH key generation and configuration
- Week 4: Firewall IP restriction
- Week 5: fail2ban deployment
- Week 5: Root login disabled

Residual Risk After Mitigation: LOW
- Key-based auth eliminates password attacks
- IP restriction blocks unauthorized sources
- fail2ban provides defense-in-depth
- Multiple layers of protection

---

THREAT 2: PRIVILEGE ESCALATION
-------------------------------

Description:
An attacker who has gained limited user access (either through compromised
credentials or application vulnerability) attempts to elevate privileges to
root/administrator level through exploitation of system vulnerabilities,
misconfigurations, or weak access controls.

Attack Vector:
- Starting Point: Limited user account access
- Method: Kernel exploits, SUID binaries, sudo misconfiguration
- Target: Root privileges
- Tools: Linux exploit suggester, privilege escalation scripts

Impact Assessment:
HIGH SEVERITY

Confidentiality:
- Access to all system files and data
- Ability to read sensitive configurations
- Access to other users' data
- Exposure of cryptographic keys

Integrity:
- Complete system control
- Ability to modify system files
- Installation of rootkits or backdoors
- Manipulation of audit logs
- Persistence mechanisms

Availability:
- Ability to disable security controls
- System shutdown or reboot capability
- Service disruption
- Denial of service against other users

Likelihood: MEDIUM
- Requires initial access to system
- Depends on system patch level
- Misconfigurations can provide opportunities
- Constant discovery of new vulnerabilities

Mitigation Strategies:

Primary Defenses:
1. Create Non-Root Administrative User
   - Implementation: adduser adminuser, add to sudo group
   - Effectiveness: Eliminates need for root login
   - Priority: CRITICAL
   - Rationale: Principle of least privilege

2. Configure sudo with Password Requirements
   - Implementation: Require password for sudo commands
   - Effectiveness: Prevents unauthorized privilege use
   - Priority: HIGH
   - File: /etc/sudoers

3. Enable AppArmor Mandatory Access Control
   - Implementation: Verify AppArmor enabled, enforce profiles
   - Effectiveness: Restricts process capabilities even if privileged
   - Priority: HIGH
   - Command: aa-status

4. Keep System Updated with Automatic Security Patches
   - Implementation: unattended-upgrades configuration
   - Effectiveness: Closes known vulnerability windows
   - Priority: CRITICAL
   - Schedule: Daily security updates

5. Implement Principle of Least Privilege
   - Implementation: Grant minimum necessary permissions
   - Effectiveness: Limits damage from compromised accounts
   - Priority: HIGH
   - Review: Regular permission audits

Secondary Defenses:
6. Monitor sudo Usage Logs
   - Implementation: Review /var/log/auth.log for sudo activity
   - Effectiveness: Detects unauthorized privilege attempts
   - Priority: MEDIUM
   - Frequency: Daily review

7. Restrict SUID/SGID Binaries
   - Implementation: Audit and remove unnecessary SUID binaries
   - Command: find / -perm -4000 -o -perm -2000
   - Effectiveness: Reduces privilege escalation vectors
   - Priority: MEDIUM

8. Implement Kernel Hardening
   - Implementation: sysctl security parameters
   - Settings: kernel.dmesg_restrict, kernel.kptr_restrict
   - Effectiveness: Limits information disclosure
   - Priority: MEDIUM

9. Enable Audit Logging (auditd)
   - Implementation: Install and configure auditd
   - Effectiveness: Detailed activity tracking
   - Priority: LOW (future enhancement)

Implementation Timeline:
- Week 4: Create admin user, configure sudo
- Week 5: Verify AppArmor enforcement
- Week 5: Enable automatic updates
- Ongoing: Regular permission reviews

Residual Risk After Mitigation: LOW-MEDIUM
- Multiple layers prevent escalation
- AppArmor limits privileged process capabilities
- Automatic updates close vulnerability windows
- Monitoring detects suspicious activity

---

THREAT 3: UNPATCHED VULNERABILITIES
------------------------------------

Description:
Known security vulnerabilities in the operating system kernel, system libraries,
or installed packages remain unpatched, providing attackers with documented
exploit paths. This includes both publicly disclosed CVEs (Common Vulnerabilities
and Exposures) and zero-day vulnerabilities discovered after deployment.

Attack Vector:
- Entry Point: Network services, applications, kernel
- Method: Exploit known CVEs with public exploit code
- Discovery: Vulnerability scanners, exploit databases
- Exploitation: Remote code execution, privilege escalation

Impact Assessment:
MEDIUM to HIGH SEVERITY (varies by vulnerability)

Confidentiality:
- Information disclosure vulnerabilities
- Memory content exposure
- Configuration file access
- Credential theft

Integrity:
- Remote code execution capabilities
- System file modification
- Backdoor installation
- Log manipulation

Availability:
- Denial of service exploits
- System crashes
- Service disruption
- Resource exhaustion

Likelihood: MEDIUM to HIGH
- Constant vulnerability discovery
- Exploit code often publicly available
- Automated exploitation tools exist
- Window between disclosure and patching

Common Vulnerability Classes:
1. Remote Code Execution (RCE) - Critical
2. Privilege Escalation - High
3. Information Disclosure - Medium
4. Denial of Service - Medium
5. Authentication Bypass - High

Mitigation Strategies:

Primary Defenses:
1. Configure Automatic Security Updates
   - Implementation: unattended-upgrades package
   - Configuration: Daily security update checks
   - Effectiveness: Reduces vulnerability window
   - Priority: CRITICAL
   - Files:
     * /etc/apt/apt.conf.d/20auto-upgrades
     * /etc/apt/apt.conf.d/50unattended-upgrades

2. Regular System Audits Using Lynis
   - Implementation: Weekly security scans
   - Command: sudo lynis audit system
   - Effectiveness: Identifies misconfigurations and missing patches
   - Priority: HIGH
   - Reporting: Document findings and remediation

3. Monitor Security Advisories
   - Sources:
     * Ubuntu Security Notices (USN)
     * CVE databases
     * Security mailing lists
   - Effectiveness: Early awareness of new vulnerabilities
   - Priority: HIGH
   - Action: Review weekly

4. Implement Update Testing Procedures
   - Implementation: Test updates in isolated environment
   - Method: VM snapshots before major updates
   - Effectiveness: Prevents update-induced issues
   - Priority: MEDIUM
   - Process: Snapshot → Update → Test → Apply to production

5. Maintain Minimal Installed Package Footprint
   - Implementation: Remove unnecessary packages
   - Command: sudo apt autoremove
   - Effectiveness: Reduces attack surface
   - Priority: MEDIUM
   - Review: Monthly package audit

Secondary Defenses:
6. Regular Vulnerability Scanning
   - Tools: Lynis, OpenVAS (future)
   - Frequency: Weekly automated scans
   - Effectiveness: Proactive vulnerability identification
   - Priority: HIGH

7. Subscribe to Security Mailing Lists
   - Lists: ubuntu-security-announce
   - Effectiveness: Immediate notification of critical issues
   - Priority: MEDIUM

8. Implement Network Segmentation
   - Implementation: Firewall rules, isolated networks
   - Effectiveness: Limits blast radius of compromise
   - Priority: MEDIUM
   - Current: Host-only network provides isolation

9. Deploy Intrusion Detection System (IDS)
   - Tool: AIDE, Tripwire (future enhancement)
   - Effectiveness: Detects unauthorized file modifications
   - Priority: LOW (future)

10. Regular Security Baseline Verification
    - Tool: security-baseline.sh script
    - Frequency: Daily automated checks
    - Effectiveness: Ensures consistent security posture
    - Priority: HIGH

Patch Management Process:

1. Monitoring Phase:
   - Automatic: unattended-upgrades checks daily
   - Manual: Weekly security advisory review
   - Tools: apt list --upgradable

2. Assessment Phase:
   - Evaluate criticality of updates
   - Review changelogs for breaking changes
   - Determine maintenance window if needed

3. Testing Phase:
   - Snapshot VM before updates
   - Apply updates in test environment
   - Verify functionality

4. Deployment Phase:
   - Automatic: Security updates applied nightly
   - Manual: Major version upgrades with testing
   - Monitoring: System behavior post-update

5. Verification Phase:
   - Confirm updates applied successfully
   - Run security baseline script
   - Check system logs for errors

Implementation Timeline:
- Week 5: Configure automatic updates
- Week 5: Install and configure Lynis
- Week 7: Perform comprehensive security audit
- Ongoing: Daily automatic patching

Residual Risk After Mitigation: LOW-MEDIUM
- Automatic updates reduce vulnerability window
- Regular audits identify gaps
- Minimal package footprint reduces exposure
- Some risk remains between vulnerability disclosure and patch application
- Zero-day vulnerabilities cannot be fully mitigated

---

THREAT MODEL SUMMARY
--------------------

Risk Matrix:

┌─────────────────────┬────────────┬──────────────┬─────────────┐
│ Threat              │ Likelihood │ Impact       │ Risk Level  │
├─────────────────────┼────────────┼──────────────┼─────────────┤
│ Brute Force SSH     │ HIGH       │ HIGH         │ CRITICAL    │
│ Privilege Escalation│ MEDIUM     │ HIGH         │ HIGH        │
│ Unpatched Vulns     │ MED-HIGH   │ MED-HIGH     │ HIGH        │
└─────────────────────┴────────────┴──────────────┴─────────────┘

Defense-in-Depth Strategy:

Layer 1: Network Security
- Firewall (UFW)
- IP-based access control
- Network segmentation (Host-only)

Layer 2: Access Control
- SSH key-based authentication
- No password authentication
- No root login

Layer 3: Intrusion Detection
- fail2ban
- Log monitoring
- Security baseline verification

Layer 4: System Hardening
- AppArmor mandatory access control
- Minimal package installation
- Secure system configuration

Layer 5: Patch Management
- Automatic security updates
- Regular vulnerability scanning
- Security advisory monitoring

Layer 6: Monitoring & Auditing
- Log review
- Security baseline checks
- Regular Lynis audits

Implementation Priority:
1. CRITICAL: SSH hardening, firewall (Week 4)
2. HIGH: fail2ban, AppArmor (Week 5)
3. HIGH: Automatic updates (Week 5)
4. MEDIUM: Monitoring and auditing (Ongoing)

================================================================================
WEEK 2 LEARNING OUTCOMES
================================================================================

Planning Skills Developed:
1. Comprehensive security planning methodology
2. Threat modeling and risk assessment
3. Performance testing strategy design
4. Defense-in-depth architecture planning
5. Prioritization of security controls

Security Understanding Gained:
1. Common attack vectors against Linux servers
2. Layered security approach (defense-in-depth)
3. Balance between security and usability
4. Importance of proactive security planning
5. Risk assessment and mitigation strategies

Documentation Skills:
1. Structured security planning documentation
2. Threat model creation with CIA impact analysis
3. Checklist development for consistent implementation
4. Testing methodology documentation
5. Clear justification of security decisions

================================================================================
IMPLEMENTATION PREPARATION
================================================================================

Week 3 Preparation (Application Selection):
- Review performance testing requirements
- Identify applications for each workload type
- Research installation procedures
- Plan monitoring approach for each application

Week 4 Preparation (Security Implementation):
- Generate SSH key pair on Windows
- Prepare firewall rules
- Plan user creation process
- Document expected configurations

Week 5 Preparation (Advanced Security):
- Research AppArmor profile management
- Prepare fail2ban configuration
- Design security baseline script
- Plan remote monitoring implementation

================================================================================
CONCLUSION
================================================================================

Week 2 established comprehensive planning for:
✓ Performance testing methodology with clear metrics
✓ Security configuration checklist covering all critical areas
✓ Detailed threat model with 3 major threats
✓ Mitigation strategies for identified risks
✓ Defense-in-depth security architecture

Planning Status: COMPLETE
Threat Model: 3 threats identified and analyzed
Security Checklist: 6 major categories defined
Testing Plan: 4-phase approach documented

Next Phase: Application Selection for Performance Testing (Week 3)

================================================================================
END OF WEEK 2 DOCUMENTATION
================================================================================
EOF
cat week2-documentation.txt