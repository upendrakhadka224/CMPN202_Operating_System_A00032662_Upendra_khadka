cat > README.md << 'EOF'
# Operating Systems Security Project

**Student:** Upendra Khadka  
**Course:** Operating Systems Security  
**Institution:** University of Roehampton  
**Completion Date:** December 24, 2025

---

## Project Overview

This project demonstrates comprehensive security hardening and performance analysis of an Ubuntu Server 24.04.3 LTS system over a 7-week implementation period.

### Key Achievements

- **Security Hardening Index:** 65/100 (Lynis audit)
- **Zero Security Warnings**
- **261 Security Tests Performed**
- **Complete Defense-in-Depth Implementation**

---

## System Configuration

### Hardware & Environment
- **Platform:** VirtualBox Virtual Machine
- **OS:** Ubuntu Server 24.04.3 LTS (Noble)
- **Kernel:** 6.14.0-37-generic
- **Architecture:** x86_64
- **RAM:** 3.1 GB
- **Disk:** 25 GB
- **Network:** Dual interface (NAT + Host-only)

### Network Configuration
- **enp0s3 (NAT):** 10.0.2.15/24 - Internet connectivity
- **enp0s8 (Host-only):** 192.168.56.101/24 - SSH management

---

## Security Implementation

### Authentication & Access Control
- ✅ SSH key-based authentication only
- ✅ Password authentication disabled
- ✅ Root login disabled
- ✅ Firewall restricted to workstation IP (192.168.56.1)
- ✅ fail2ban intrusion detection active
- ✅ AppArmor mandatory access control (129 profiles, 32 enforced)

### Security Services
- **SSH:** Hardened configuration, port 22
- **UFW Firewall:** Active, deny-by-default policy
- **fail2ban:** Monitoring SSH authentication attempts
- **AppArmor:** System-wide mandatory access control
- **unattended-upgrades:** Automatic security patching

---

## Performance Metrics

### Baseline Performance
- **CPU:** 6,466 operations/sec (4 cores under load)
- **Memory:** 119,261 operations/sec (2GB stress test)
- **Disk Write:** 5,282 KiB/s (1,320 IOPS)
- **Disk Read:** 4,611 KiB/s (1,152 IOPS)
- **Network:** 25.2 Gbits/sec (loopback)
- **Web Server:** 3,978 requests/sec (nginx)

### Optimizations Applied
1. **File Descriptors:** Increased from 1,024 to 65,536
2. **Swappiness:** Reduced from 60 to 10

---

## Project Phases

### Week 1: System Planning & Installation
- Ubuntu Server 24.04.3 LTS installation
- Dual network interface configuration
- System specification documentation
- Distribution selection justification

### Week 2: Security Planning
- Performance testing methodology design
- Security configuration checklist creation
- Threat model development (3 threats identified)
- Mitigation strategy planning

### Week 3: Application Selection
- stress-ng (CPU/RAM testing)
- fio (Disk I/O testing)
- iperf3 (Network testing)
- nginx (Web server)
- htop (System monitoring)
- Apache Bench (Load testing)

### Week 4: Initial Security Configuration
- SSH key-based authentication implementation
- UFW firewall configuration
- Administrative user creation
- Remote access verification

### Week 5: Advanced Security & Monitoring
- AppArmor configuration and verification
- Automatic security updates enabled
- fail2ban intrusion detection implemented
- Security baseline script created
- Remote monitoring script developed

### Week 6: Performance Testing & Optimization
- Baseline performance measurement
- CPU stress testing
- Memory stress testing
- Disk I/O performance analysis
- Network bandwidth testing
- Web server load testing
- System optimization implementation

### Week 7: Security Audit & Evaluation
- Lynis security audit (65/100 hardening index)
- Nmap network security assessment
- Service inventory and justification
- AppArmor verification
- Final security posture evaluation

---

## Security Audit Results

### Lynis Security Scan
- **Hardening Index:** 65/100
- **Tests Performed:** 261
- **Warnings:** 0
- **Status:** GOOD
- **Assessment:** System has been hardened, suitable for production

### Network Security (Nmap)
- **Open Ports:** 3 (SSH:22, HTTP:80, iperf3:5201)
- **Attack Surface:** Minimal
- **SSH Configuration:** Hardened
- **Firewall:** Properly configured

### Access Control
- **AppArmor Status:** Active
- **Profiles Loaded:** 129
- **Profiles Enforced:** 32
- **Unconfined Processes:** 115

---

## Key Scripts

### security-baseline.sh
Comprehensive security verification script that checks:
- SSH configuration
- Firewall status
- fail2ban monitoring
- Automatic updates
- AppArmor status
- Administrative users
- Pending security updates

### monitor-server.sh (Windows PowerShell)
Remote monitoring script for:
- System uptime and load
- Memory usage
- Disk usage
- CPU utilization
- Network statistics
- Service status

---

## Technologies Used

- **Operating System:** Ubuntu Server 24.04.3 LTS
- **Virtualization:** Oracle VirtualBox
- **Security Tools:** UFW, fail2ban, AppArmor, Lynis, Nmap
- **Testing Tools:** stress-ng, fio, iperf3, Apache Bench
- **Monitoring:** htop, vmstat, iostat
- **Remote Access:** OpenSSH

---

## Documentation

- **GitHub Pages Journal:** [Link to your journal]
- **Video Demonstration:** 8 minutes showcasing system configuration and security
- **Screenshots:** Complete evidence for all 7 weeks
- **Configuration Files:** Backed up and documented

---

## Security Trade-offs

### Security vs Performance
- **Security Overhead:** Approximately 5-10%
- **Justification:** Comprehensive protection against:
  - Brute force attacks
  - Unauthorized access
  - Privilege escalation
  - Unpatched vulnerabilities

### Conclusion
The minimal performance impact (5-10%) is acceptable given the substantial security improvements. The system demonstrates that effective security and acceptable performance can coexist.

---

## Risk Assessment

### Mitigated Risks
✅ Brute force SSH attacks (SSH keys + fail2ban + firewall)  
✅ Unauthorized access (Key-based auth only)  
✅ Privilege escalation (AppArmor + sudo controls)  
✅ Unpatched vulnerabilities (Automatic updates)  

### Remaining Risks (Low)
- Virtual machine environment (inherently isolated)
- No SSL/TLS on nginx (future enhancement)
- Some AppArmor profiles in complain mode

### Recommendations
1. Implement SSL/TLS for nginx (HTTPS)
2. Enable additional AppArmor profiles in enforce mode
3. Add file integrity monitoring (AIDE/Tripwire)
4. Enable auditd for detailed system logging

---

## Future Enhancements

1. **SSL/TLS Implementation**
   - Configure HTTPS for nginx
   - Obtain Let's Encrypt certificate

2. **Enhanced Monitoring**
   - Implement centralized logging
   - Add intrusion detection system (IDS)
   - Configure email alerts for security events

3. **Additional Hardening**
   - Implement more AppArmor profiles
   - Add file integrity monitoring
   - Enable audit daemon (auditd)

4. **Performance Optimization**
   - Tune kernel parameters further
   - Optimize nginx configuration
   - Implement caching strategies

---

## Commands Reference

### System Information
```bash
uname -a
free -h
df -h
ip addr show
lsb_release -a
```

### Security Checks
```bash
sudo systemctl status ssh
sudo ufw status verbose
sudo fail2ban-client status sshd
sudo aa-status
```

### Performance Testing
```bash
stress-ng --cpu 4 --timeout 60s --metrics-brief
fio --name=test --size=1G --rw=write --ioengine=sync --direct=1
iperf3 -c localhost -t 30
ab -n 1000 -c 10 http://localhost/
```

### Remote Monitoring (from Windows)
```powershell
ssh -i "path/to/key" upendra@192.168.56.101 "uptime"
ssh -i "path/to/key" upendra@192.168.56.101 "free -h"
ssh -i "path/to/key" upendra@192.168.56.101 "df -h"
```

---



## Contact

**Upendra Khadka**  
University of Roehampton  
Operating Systems Security Course  

---

## License

This project is for educational purposes as part of the Operating Systems Security course at University of Roehampton.

---

## Acknowledgments

- University of Roehampton for course curriculum
- Ubuntu community for extensive documentation
- CISOfy for Lynis security auditing tool
- All open-source security tool developers

---

**Project Status:** ✅ COMPLETE  
**System Status:** 🟢 PRODUCTION READY  
**Security Rating:** 65/100 (GOOD)

EOF
cat README.md