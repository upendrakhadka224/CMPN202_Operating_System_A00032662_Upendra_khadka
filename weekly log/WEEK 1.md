
================================================================================
WEEK 1: SYSTEM PLANNING AND DISTRIBUTION SELECTION
================================================================================

Student: Upendra Khadka
Institution: University of Roehampton
Date: December 2025

================================================================================
PHASE 1 OBJECTIVES
================================================================================

1. Plan operating system deployment
2. Select and justify distribution choice
3. Configure network infrastructure
4. Document system specifications
5. Establish baseline configuration

================================================================================
SYSTEM ARCHITECTURE
================================================================================

Deployment Environment:
- Virtualization Platform: Oracle VirtualBox
- Host OS: Windows
- Guest OS: Ubuntu Server 24.04.3 LTS

Virtual Machine Specifications:
- CPU Cores: 4
- RAM: 3.1 GB (3200 MB allocated)
- Disk: 25 GB virtual hard disk
- Network Adapters: 2 (NAT + Host-only)

Network Architecture:
┌─────────────────────────────────────────────────────┐
│                  Windows Host                        │
│              (192.168.56.1)                         │
└────────────────┬────────────────────────────────────┘
                 │
                 │ Host-only Network
                 │ (192.168.56.0/24)
                 │
┌────────────────┴────────────────────────────────────┐
│            Ubuntu Server VM                          │
│                                                      │
│  enp0s8: 192.168.56.101  ←─ SSH Management         │
│  enp0s3: 10.0.2.15       ←─ Internet (NAT)         │
│                                                      │
└──────────────────────────────────────────────────────┘

================================================================================
DISTRIBUTION SELECTION JUSTIFICATION
================================================================================

Selected Distribution: Ubuntu Server 24.04.3 LTS (Noble Numbat)

Comparison Matrix:
┌──────────────────┬─────────┬──────────┬───────────┬──────────┐
│ Distribution     │ LTS     │ Security │ Community │ Choice   │
├──────────────────┼─────────┼──────────┼───────────┼──────────┤
│ Ubuntu 24.04 LTS │ 5 years │ Excellent│ Extensive │ SELECTED │
│ Debian 12        │ 5 years │ Excellent│ Strong    │ -        │
│ CentOS Stream    │ Rolling │ Good     │ Moderate  │ -        │
│ Rocky Linux      │ 10 years│ Excellent│ Growing   │ -        │
└──────────────────┴─────────┴──────────┴───────────┴──────────┘

Justification for Ubuntu Server 24.04.3 LTS:

1. Long-Term Support (LTS)
   - 5 years of security updates (until 2029)
   - Stable release cycle
   - Production-ready platform

2. Security Features
   - AppArmor mandatory access control (default)
   - Extensive security tooling available
   - Regular security updates via unattended-upgrades
   - Strong community security focus

3. Documentation & Support
   - Comprehensive official documentation
   - Large community knowledge base
   - Extensive tutorials and guides
   - Active forums and support channels

4. Package Availability
   - Large software repository
   - Easy installation of security tools
   - Compatible with most enterprise software
   - APT package manager (user-friendly)

5. Industry Standard
   - Widely used in enterprise environments
   - Well-supported by third-party vendors
   - Common in cloud deployments
   - Familiar to most system administrators

Alternative Considerations:

Debian 12 (Not Selected):
- Pros: More stable, longer support in some cases
- Cons: Older packages, slower update cycle

CentOS Stream (Not Selected):
- Pros: RHEL-based, enterprise focus
- Cons: Rolling release model less stable

Rocky Linux (Not Selected):
- Pros: 10-year support, RHEL clone
- Cons: Smaller community, newer project

================================================================================
WORKSTATION CONFIGURATION DECISION
================================================================================

Selected Configuration: Windows Host + Ubuntu Server VM

Justification:

1. Development Environment
   - Windows as primary workstation OS
   - VirtualBox for isolated testing
   - Easy snapshot and rollback capability
   - No risk to host system

2. Network Isolation
   - VM provides isolated test environment
   - Safe for security testing
   - Controlled network access
   - Easy to reset if compromised

3. Learning Benefits
   - Practice SSH remote administration
   - Realistic client-server setup
   - Mirrors production environments
   - Safe experimentation platform

================================================================================
NETWORK CONFIGURATION DOCUMENTATION
================================================================================

VirtualBox Network Settings:

Adapter 1 (NAT):
- Purpose: Internet connectivity
- IP Address: 10.0.2.15/24 (DHCP)
- Gateway: 10.0.2.2
- DNS: Automatic
- Use Case: Package downloads, updates, external access

Adapter 2 (Host-only):
- Purpose: SSH management from Windows
- IP Address: 192.168.56.101/24 (DHCP)
- Network: VirtualBox Host-Only Ethernet Adapter
- Gateway: None (isolated network)
- Use Case: Secure administrative access

Port Forwarding (NAT Adapter):
- SSH: Host 127.0.0.1:2222 → Guest 192.168.56.101:22
- Purpose: Alternative SSH access method

IP Addressing Scheme:
┌────────────────┬─────────────────┬────────────────────┐
│ Interface      │ IP Address      │ Purpose            │
├────────────────┼─────────────────┼────────────────────┤
│ enp0s3 (NAT)   │ 10.0.2.15/24    │ Internet access    │
│ enp0s8 (Host)  │ 192.168.56.101  │ SSH management     │
│ lo (loopback)  │ 127.0.0.1/8     │ Local services     │
└────────────────┴─────────────────┴────────────────────┘

================================================================================
SYSTEM SPECIFICATIONS (CLI DOCUMENTATION)
================================================================================

Command: uname -a
Output:
Linux ubuntu 6.14.0-37-generic #37~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC 
Thu Nov 20 10:25:38 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

Analysis:
- Kernel Version: 6.14.0-37-generic
- Architecture: x86_64 (64-bit)
- SMP: Symmetric multiprocessing enabled
- PREEMPT_DYNAMIC: Dynamic preemption for better responsiveness

---

Command: free -h
Output:
               total        used        free      shared  buff/cache   available
Mem:           3.1Gi       883Mi       1.4Gi        27Mi       1.0Gi       2.3Gi
Swap:             0B          0B          0B

Analysis:
- Total RAM: 3.1 GB
- Used: 883 MB (28%)
- Available: 2.3 GB (72%)
- Swap: 0 GB (not configured - VM environment)
- System has adequate memory for testing

---

Command: df -h
Output:
Filesystem      Size  Used Avail Use% Mounted on
tmpfs           322M  1.4M  321M   1% /run
/dev/sda2        25G  4.4G   19G  19% /
tmpfs           1.6G     0  1.6G   0% /dev/shm
tmpfs           5.0M  8.0K  5.0M   1% /run/lock
tmpfs           322M  116K  322M   1% /run/user/1000

Analysis:
- Root filesystem (/): 25 GB total, 4.4 GB used (19%)
- Available space: 19 GB (sufficient for testing)
- Disk: /dev/sda2 (single partition design)
- tmpfs: Memory-based temporary filesystems

---

Command: ip addr show
Output:
1: lo: <LOOPBACK,UP,LOWER_UP>
    inet 127.0.0.1/8 scope host lo
    
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP>
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
    
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP>
    inet 192.168.56.101/24 brd 192.168.56.255 scope global dynamic noprefixroute enp0s8

Analysis:
- Loopback (lo): 127.0.0.1 - functioning correctly
- NAT interface (enp0s3): 10.0.2.15 - internet connectivity
- Host-only interface (enp0s8): 192.168.56.101 - SSH management
- All interfaces UP and RUNNING
- DHCP configuration working correctly

---

Command: lsb_release -a
Output:
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 24.04.3 LTS
Release:        24.04
Codename:       noble

Analysis:
- Distribution: Ubuntu Server
- Version: 24.04.3 LTS (Noble Numbat)
- LTS Status: Long-term support until 2029
- Release Type: Stable production release

---

Command: hostname
Output:
ubuntu

Analysis:
- Hostname: ubuntu (default configuration)
- FQDN: Not configured (not required for testing)
- DNS: Resolving via systemd-resolved

================================================================================
INITIAL ASSESSMENT
================================================================================

System Readiness:
✓ Operating system successfully installed
✓ Dual network configuration functional
✓ Internet connectivity established
✓ SSH service ready (to be configured in Week 4)
✓ Adequate resources for testing
✓ System responsive and stable

Resource Allocation Assessment:
✓ CPU: 4 cores sufficient for stress testing
✓ RAM: 3.1 GB adequate for applications
✓ Disk: 25 GB sufficient with 81% free
✓ Network: Dual adapters working correctly

System Health:
✓ No errors in system logs
✓ All filesystems mounted correctly
✓ Network interfaces operational
✓ Services starting normally

================================================================================
WEEK 1 DELIVERABLES CHECKLIST
================================================================================

Documentation:
☑ System Architecture Diagram created
☑ Distribution Selection Justification completed
☑ Workstation configuration decision documented
☑ Network configuration documented
☑ CLI system specifications captured

Technical Implementation:
☑ Ubuntu Server 24.04.3 LTS installed
☑ VirtualBox network adapters configured
☑ IP addressing functional
☑ System specifications verified
☑ Baseline system stable and ready

Evidence:
☑ Screenshots of uname output
☑ Screenshots of free -h output
☑ Screenshots of df -h output
☑ Screenshots of ip addr output
☑ Screenshots of lsb_release output
☑ VirtualBox network settings captured

================================================================================
LEARNING OUTCOMES - WEEK 1
================================================================================

Technical Skills Developed:
1. Virtual machine deployment and configuration
2. Network adapter configuration (NAT + Host-only)
3. Linux command-line system analysis
4. IP addressing and network design
5. Documentation and justification skills

Understanding Gained:
1. Importance of distribution selection
2. Network isolation for security testing
3. System resource requirements
4. Linux filesystem structure
5. Network interface configuration

Decisions Made:
1. Ubuntu Server 24.04.3 LTS selected for stability and support
2. Dual network adapter approach for security and connectivity
3. VirtualBox chosen for safe testing environment
4. Resource allocation balanced for performance testing
5. Standard Ubuntu configuration for wide applicability

================================================================================
NEXT STEPS (WEEK 2)
================================================================================

Planning Tasks:
- Design performance testing methodology
- Create security configuration checklist
- Develop threat model (minimum 3 threats)
- Plan mitigation strategies
- Document testing approach

Preparation:
- Research security best practices
- Identify required tools and applications
- Plan monitoring strategy
- Design security baseline
- Prepare for Week 3 application selection

================================================================================
CONCLUSION
================================================================================

Week 1 successfully established the foundation for the security project:
- Stable Ubuntu Server 24.04.3 LTS deployment
- Properly configured network infrastructure
- Documented system specifications
- Justified technical decisions
- Ready for security implementation phases

System Status: READY FOR PHASE 2
Next Phase: Security Planning and Testing Methodology

================================================================================
END OF WEEK 1 DOCUMENTATION
================================================================================
