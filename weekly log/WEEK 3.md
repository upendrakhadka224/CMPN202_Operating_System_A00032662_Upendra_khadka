cat > week3-documentation.txt << 'EOF'
================================================================================
WEEK 3: APPLICATION SELECTION FOR PERFORMANCE TESTING
================================================================================

Student: Upendra Khadka
Institution: University of Roehampton
Date: December 2025

================================================================================
PHASE 3 OBJECTIVES
================================================================================

1. Select applications representing different workload types
2. Document justification for each application choice
3. Install all selected applications via SSH
4. Verify successful installations
5. Define expected resource profiles
6. Establish monitoring strategy for each application

================================================================================
DELIVERABLE 1: APPLICATION SELECTION MATRIX
================================================================================

SELECTION CRITERIA
------------------

Applications were selected based on:
1. Workload Representation: Each represents a distinct resource pattern
2. Industry Standard: Widely used in performance testing
3. Measurable Output: Provides quantifiable metrics
4. SSH Installation: Can be installed remotely via command line
5. Resource Variety: Tests different system components

WORKLOAD TYPE DEFINITIONS
--------------------------

CPU-Intensive:
- Primary resource: Processor cycles
- Characteristic: High CPU utilization, low I/O
- Use case: Computational tasks, encoding, compilation

RAM-Intensive:
- Primary resource: System memory
- Characteristic: Large memory allocation, cache usage
- Use case: In-memory databases, virtual machines

I/O-Intensive:
- Primary resource: Disk subsystem
- Characteristic: High read/write operations
- Use case: Database operations, file servers

Network-Intensive:
- Primary resource: Network bandwidth
- Characteristic: High data transfer rates
- Use case: File transfers, streaming, web services

Server Application:
- Resource mix: CPU, memory, network combined
- Characteristic: Concurrent connection handling
- Use case: Production web/application servers

================================================================================
SELECTED APPLICATIONS
================================================================================

APPLICATION 1: stress-ng (CPU-INTENSIVE)
----------------------------------------

Application Details:
- Name: stress-ng
- Version: 0.17.06
- License: GPL v2
- Developer: Colin King
- Repository: Ubuntu main repository

Purpose:
Stress testing tool specifically designed to exercise CPU cores with
various computational workloads. Provides precise control over CPU
utilization and core allocation.

Workload Type: CPU-INTENSIVE

Justification:
1. Industry Standard: Widely used in Linux performance testing
2. Precise Control: Can specify exact number of CPU workers
3. Quantifiable Metrics: Provides operations per second measurements
4. Reproducible: Consistent results across test runs
5. Multiple Methods: Supports various CPU stress algorithms
6. Built-in Metrics: Reports timing and performance data

Installation Method:
SSH-based installation via APT package manager

Expected Resource Profile:
- CPU Usage: Up to 100% per specified core
- Memory Usage: Minimal (< 50 MB)
- Disk I/O: Negligible
- Network Usage: None
- Typical Operations: 5,000-10,000 ops/sec per core

Test Parameters:
stress-ng --cpu 2 --timeout 60s --metrics-brief
stress-ng --cpu 4 --timeout 60s --metrics-brief

Monitoring Metrics:
- CPU utilization percentage
- Operations per second (bogo ops)
- Load average
- CPU temperature (if available)
- Context switches

---

APPLICATION 2: stress-ng (RAM-INTENSIVE)
----------------------------------------

Application Details:
- Name: stress-ng (memory mode)
- Version: 0.17.06
- License: GPL v2
- Mode: Virtual memory stressor

Purpose:
Tests system memory allocation, management, and performance by creating
virtual memory workers that continuously allocate and access memory.

Workload Type: RAM-INTENSIVE

Justification:
1. Memory Allocation: Tests actual memory subsystem performance
2. Configurable Size: Precise control over memory usage
3. Multiple Workers: Can test concurrent memory access
4. Page Fault Testing: Exercises virtual memory system
5. Cache Effects: Tests L1/L2/L3 cache performance
6. Quantifiable Results: Operations per second metrics

Installation Method:
Same package as CPU testing (stress-ng)

Expected Resource Profile:
- CPU Usage: Moderate (20-40%)
- Memory Usage: Configurable (512MB - 2GB test ranges)
- Disk I/O: Low (swap if memory exhausted)
- Network Usage: None
- Typical Operations: 100,000+ ops/sec

Test Parameters:
stress-ng --vm 1 --vm-bytes 512M --timeout 60s --metrics-brief
stress-ng --vm 2 --vm-bytes 1G --timeout 60s --metrics-brief

Monitoring Metrics:
- Memory usage (used/free/available)
- Swap usage (if applicable)
- Page faults per second
- Cache hit/miss rates
- Memory bandwidth

---

APPLICATION 3: fio (I/O-INTENSIVE)
----------------------------------

Application Details:
- Name: fio (Flexible I/O Tester)
- Version: 3.36
- License: GPL v2
- Developer: Jens Axboe
- Type: Advanced I/O testing tool

Purpose:
Industry-standard tool for testing and benchmarking disk I/O performance.
Supports multiple I/O engines, access patterns, and block sizes for
comprehensive storage subsystem evaluation.

Workload Type: I/O-INTENSIVE

Justification:
1. Industry Benchmark: Standard tool for storage performance testing
2. Flexible Configuration: Supports various I/O patterns (sequential, random)
3. Multiple I/O Engines: sync, libaio, mmap, etc.
4. Detailed Metrics: IOPS, bandwidth, latency statistics
5. Reproducible: Consistent test methodology
6. Direct I/O: Bypasses cache for accurate disk measurement

Installation Method:
SSH-based installation via APT

Expected Resource Profile:
- CPU Usage: Low to moderate (10-30%)
- Memory Usage: Minimal (< 100 MB)
- Disk I/O: Maximum throughput (primary focus)
- Network Usage: None
- Typical Performance:
  * Sequential Read: 80-150 MB/s (VM environment)
  * Sequential Write: 80-150 MB/s
  * Random Read: 5,000-15,000 IOPS (4K blocks)
  * Random Write: 5,000-15,000 IOPS

Test Parameters:
# Sequential Write Test
fio --name=write-test --size=1G --rw=write --ioengine=sync --direct=1 --bs=4k

# Sequential Read Test
fio --name=read-test --size=1G --rw=read --ioengine=sync --direct=1 --bs=4k

# Random Read/Write Test
fio --name=random-test --size=500M --rw=randrw --ioengine=sync --direct=1 --bs=4k

Monitoring Metrics:
- IOPS (Input/Output Operations Per Second)
- Bandwidth (MB/s or KiB/s)
- Latency (average, min, max in microseconds)
- CPU usage during I/O operations
- Disk utilization percentage

---

APPLICATION 4: iperf3 (NETWORK-INTENSIVE)
-----------------------------------------

Application Details:
- Name: iperf3
- Version: 3.16
- License: BSD-style
- Developer: ESnet (Energy Sciences Network)
- Type: Network bandwidth measurement tool

Purpose:
Measures maximum achievable bandwidth on IP networks. Supports TCP and UDP
testing with detailed statistics including throughput, jitter, and packet loss.

Workload Type: NETWORK-INTENSIVE

Justification:
1. Standard Tool: Widely used for network performance testing
2. Bidirectional Testing: Supports client/server architecture
3. Multiple Protocols: TCP and UDP support
4. Real-time Statistics: Live bandwidth measurements
5. Reproducible: Consistent methodology
6. Detailed Reporting: Comprehensive performance data

Installation Method:
SSH-based installation via APT

Expected Resource Profile:
- CPU Usage: Moderate (20-50% at high speeds)
- Memory Usage: Minimal (< 50 MB)
- Disk I/O: None
- Network Usage: Maximum available bandwidth
- Typical Performance:
  * Loopback: 20-30 Gbits/sec
  * Physical network: Depends on interface speed

Test Parameters:
# Server mode (on Ubuntu)
iperf3 -s -D

# Client mode (from Ubuntu to itself)
iperf3 -c localhost -t 30

# From Windows to Ubuntu (if iperf3 available)
iperf3 -c 192.168.56.101 -t 30

Monitoring Metrics:
- Bandwidth (Mbits/sec or Gbits/sec)
- Transfer size (MB or GB)
- Retransmissions
- Jitter (for UDP tests)
- Packet loss percentage
- CPU usage during transfer

---

APPLICATION 5: nginx (SERVER APPLICATION)
-----------------------------------------

Application Details:
- Name: nginx (Engine X)
- Version: 1.24.0 (Ubuntu)
- License: 2-clause BSD
- Developer: Igor Sysoev / Nginx, Inc.
- Type: High-performance web server

Purpose:
Production-grade web server used to test server application performance,
concurrent connection handling, and request processing under load.

Workload Type: SERVER APPLICATION

Justification:
1. Production Software: Real-world server application
2. Concurrent Connections: Tests multiple resource types simultaneously
3. Industry Standard: Widely deployed web server
4. Load Testing: Compatible with Apache Bench (ab)
5. Resource Mix: Tests CPU, memory, and network together
6. Scalability: Performance under varying connection counts

Installation Method:
SSH-based installation via APT

Expected Resource Profile:
- CPU Usage: Variable (low idle, high under load)
- Memory Usage: Moderate (50-200 MB depending on load)
- Disk I/O: Low (serving static content)
- Network Usage: High under load testing
- Typical Performance:
  * Requests/second: 2,000-5,000 (depends on concurrency)
  * Latency: 1-5 ms per request
  * Concurrent connections: 100-1,000+

Test Parameters:
# Apache Bench load testing
ab -n 1000 -c 10 http://localhost/
ab -n 5000 -c 50 http://localhost/

# Verify nginx status
sudo systemctl status nginx
curl -I localhost

Monitoring Metrics:
- Requests per second
- Time per request (mean)
- Transfer rate (KB/s)
- Failed requests
- CPU usage during load
- Memory usage during load
- Active connections

---

APPLICATION 6: htop (MONITORING TOOL)
-------------------------------------

Application Details:
- Name: htop
- Version: 3.3.0
- License: GPL v2
- Type: Interactive process viewer

Purpose:
Real-time system monitoring tool for observing resource usage during
performance tests. Provides visual representation of CPU, memory, and
process activity.

Workload Type: MONITORING (Support Tool)

Justification:
1. Real-time Visualization: Live system state observation
2. Process Details: Detailed per-process resource usage
3. Interactive: Allows sorting and filtering
4. Color-coded: Easy interpretation of metrics
5. System Overview: Combined CPU, memory, load display
6. SSH Compatible: Works over terminal connections

Installation Method:
SSH-based installation via APT

Expected Resource Profile:
- CPU Usage: Minimal (< 5%)
- Memory Usage: Minimal (< 20 MB)
- Disk I/O: Negligible
- Network Usage: None

Usage:
htop (interactive mode)
Press F10 or 'q' to quit

Monitoring Capabilities:
- Per-core CPU utilization
- Memory and swap usage
- Process list with resource consumption
- Load averages
- System uptime

---

APPLICATION 7: Apache Bench (LOAD TESTING)
------------------------------------------

Application Details:
- Name: ab (Apache HTTP server benchmarking tool)
- Version: 2.3 (from apache2-utils package)
- License: Apache License 2.0
- Type: HTTP load testing tool

Purpose:
Generates HTTP load for testing web server performance. Creates multiple
concurrent connections and measures response times, throughput, and reliability.

Workload Type: NETWORK/SERVER LOAD TESTING (Support Tool)

Justification:
1. Standard Tool: Widely used for web server benchmarking
2. Concurrency Control: Configurable connection count
3. Detailed Statistics: Percentile response times
4. Simple Usage: Command-line interface
5. Reproducible: Consistent test methodology
6. nginx Compatible: Works with any HTTP server

Installation Method:
SSH-based installation via APT (apache2-utils package)

Expected Resource Profile:
- CPU Usage: Moderate during test execution
- Memory Usage: Minimal
- Disk I/O: None
- Network Usage: Generates HTTP traffic

Test Parameters:
ab -n 1000 -c 10 http://localhost/
ab -n 5000 -c 50 http://localhost/

Output Metrics:
- Requests per second
- Time per request
- Transfer rate
- Connection times (min/mean/max)
- Failed requests
- Percentage of requests within time ranges

================================================================================
APPLICATION SELECTION MATRIX (SUMMARY TABLE)
================================================================================

┌─────────────┬──────────────────┬─────────┬────────────────────────────┐
│ Application │ Workload Type    │ Version │ Primary Purpose            │
├─────────────┼──────────────────┼─────────┼────────────────────────────┤
│ stress-ng   │ CPU-intensive    │ 0.17.06 │ CPU stress, multi-core     │
│ stress-ng   │ RAM-intensive    │ 0.17.06 │ Memory allocation testing  │
│ fio         │ I/O-intensive    │ 3.36    │ Disk performance (IOPS)    │
│ iperf3      │ Network-intensive│ 3.16    │ Network bandwidth testing  │
│ nginx       │ Server app       │ 1.24.0  │ Web server load testing    │
│ htop        │ Monitoring       │ 3.3.0   │ Real-time process viewer   │
│ ab          │ Load testing     │ 2.3     │ HTTP benchmarking          │
└─────────────┴──────────────────┴─────────┴────────────────────────────┘

================================================================================
DELIVERABLE 2: INSTALLATION DOCUMENTATION
================================================================================

INSTALLATION METHODOLOGY
------------------------

Connection Method:
All installations performed via SSH from Windows workstation to ensure
remote administration capability and documentation of exact commands.

SSH Connection Command:
ssh -i "C:\Users\Admin\OneDrive\Desktop\Upendra-Ubuntu\id_ed25519" upendra@192.168.56.101

Installation Approach:
1. Update package lists
2. Install each application via APT
3. Verify installation success
4. Check application versions
5. Locate binary paths
6. Test basic functionality

INSTALLATION COMMANDS
---------------------

Step 1: Update Package Lists
Command:
sudo apt update

Purpose: Refresh package database
Expected Output: Package lists updated successfully
Duration: 10-30 seconds

---

Step 2: Install stress-ng
Command:
sudo apt install stress-ng -y

Purpose: Install CPU and memory stress testing tool
Package Size: ~350 KB
Dependencies: libc6, libgcc-s1
Installation Time: 5-10 seconds
Installed Location: /usr/bin/stress-ng

Verification:
stress-ng --version
which stress-ng

Expected Output:
stress-ng, version 0.17.06
/usr/bin/stress-ng

---

Step 3: Install fio
Command:
sudo apt install fio -y

Purpose: Install flexible I/O tester
Package Size: ~500 KB
Dependencies: libaio1, zlib1g
Installation Time: 5-10 seconds
Installed Location: /usr/bin/fio

Verification:
fio --version
which fio

Expected Output:
fio-3.36
/usr/bin/fio

---

Step 4: Install iperf3
Command:
sudo apt install iperf3 -y

Purpose: Install network bandwidth measurement tool
Package Size: ~100 KB
Dependencies: libc6, libiperf0
Installation Time: 3-5 seconds
Installed Location: /usr/bin/iperf3

Verification:
iperf3 --version
which iperf3

Expected Output:
iperf 3.16
/usr/bin/iperf3

---

Step 5: Install nginx
Command:
sudo apt install nginx -y

Purpose: Install web server for application testing
Package Size: ~600 KB + dependencies
Dependencies: nginx-common, nginx-core
Installation Time: 10-20 seconds
Installed Location: /usr/sbin/nginx

Post-Installation:
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx

Verification:
nginx -v
which nginx
curl localhost

Expected Output:
nginx version: nginx/1.24.0 (Ubuntu)
/usr/sbin/nginx
HTML content from nginx welcome page

---

Step 6: Install htop
Command:
sudo apt install htop -y

Purpose: Install interactive process viewer
Package Size: ~150 KB
Dependencies: libc6, libncursesw6
Installation Time: 3-5 seconds
Installed Location: /usr/bin/htop

Verification:
htop --version
which htop

Expected Output:
htop 3.3.0
/usr/bin/htop

---

Step 7: Install Apache Bench
Command:
sudo apt install apache2-utils -y

Purpose: Install HTTP load testing tools
Package Size: ~200 KB
Dependencies: libapr1, libaprutil1
Installation Time: 5-10 seconds
Installed Location: /usr/bin/ab

Verification:
ab -V
which ab

Expected Output:
Apache HTTP server benchmarking tool
Version 2.3
/usr/bin/ab

---

COMBINED INSTALLATION COMMAND
------------------------------

All applications can be installed with a single command:

sudo apt update && sudo apt install stress-ng fio iperf3 nginx htop apache2-utils -y

Total Installation Time: ~1-2 minutes
Total Disk Space: ~10-15 MB

================================================================================
INSTALLATION VERIFICATION RESULTS
================================================================================

Application: stress-ng
Status: ✓ INSTALLED
Version: 0.17.06
Location: /usr/bin/stress-ng
Test Command: stress-ng --cpu 1 --timeout 5s --metrics-brief
Test Result: SUCCESS - 2,507 operations/sec

Application: fio
Status: ✓ INSTALLED
Version: 3.36
Location: /usr/bin/fio
Test Command: fio --name=test --size=10M --rw=write --ioengine=sync
Test Result: SUCCESS - Write test completed

Application: iperf3
Status: ✓ INSTALLED
Version: 3.16
Location: /usr/bin/iperf3
Test Command: iperf3 -s -D (daemon mode)
Test Result: SUCCESS - Server started on port 5201

Application: nginx
Status: ✓ INSTALLED
Version: 1.24.0
Location: /usr/sbin/nginx
Test Command: curl localhost
Test Result: SUCCESS - HTTP 200 OK response

Application: htop
Status: ✓ INSTALLED
Version: 3.3.0
Location: /usr/bin/htop
Test Command: htop --version
Test Result: SUCCESS - Version displayed

Application: Apache Bench
Status: ✓ INSTALLED
Version: 2.3
Location: /usr/bin/ab
Test Command: ab -n 10 -c 1 http://localhost/
Test Result: SUCCESS - 10 requests completed

All Applications: ✓ SUCCESSFULLY INSTALLED AND VERIFIED

================================================================================
DELIVERABLE 3: EXPECTED RESOURCE PROFILES
================================================================================

BASELINE SYSTEM STATE (IDLE)
-----------------------------

Before running any performance tests, baseline system state:

CPU Usage: 0-5% (idle)
Load Average: 0.20-0.30 (1/5/15 min)
Memory Used: 880-900 MB
Memory Available: 2.2-2.3 GB
Disk Usage: 19% (4.4 GB used)
Network Traffic: Minimal (< 1 KB/s)

EXPECTED PROFILES BY APPLICATION
---------------------------------

Profile 1: stress-ng (CPU Test)
Test: stress-ng --cpu 4 --timeout 60s

Expected CPU Usage: 95-100% per core tested
Expected Load Average: 4.0+ (during test)
Expected Memory: < 50 MB additional
Expected Disk I/O: Negligible
Expected Network: None
Expected Operations: 5,000-7,000 ops/sec per core
Duration: 60 seconds
Recovery Time: < 5 seconds after test

Monitoring Points:
- CPU utilization per core
- Temperature (if sensors available)
- Context switches
- System responsiveness

---

Profile 2: stress-ng (Memory Test)
Test: stress-ng --vm 2 --vm-bytes 1G

Expected CPU Usage: 30-50%
Expected Load Average: 1.0-2.0
Expected Memory: 1.0-1.2 GB allocated
Expected Disk I/O: Low (unless swapping)
Expected Network: None
Expected Operations: 100,000-150,000 ops/sec
Duration: 60 seconds
Recovery Time: Immediate after test

Monitoring Points:
- Memory usage (used/free/available)
- Swap usage (should remain 0)
- Page faults
- Memory bandwidth

---

Profile 3: fio (Disk Write Test)
Test: fio --name=write-test --size=1G --rw=write --ioengine=sync --direct=1 --bs=4k

Expected CPU Usage: 20-40%
Expected Load Average: 0.5-1.5
Expected Memory: < 100 MB
Expected Disk I/O: Maximum throughput
Expected Network: None
Expected IOPS: 1,000-1,500
Expected Bandwidth: 4-6 MB/s
Expected Latency: 700-1,000 μs
Duration: 180-240 seconds (1GB write)
Recovery Time: Immediate

Monitoring Points:
- Disk write IOPS
- Write bandwidth (MB/s)
- Average latency
- CPU I/O wait percentage
- Disk utilization

---

Profile 4: fio (Disk Read Test)
Test: fio --name=read-test --size=1G --rw=read --ioengine=sync --direct=1 --bs=4k

Expected CPU Usage: 15-35%
Expected Load Average: 0.5-1.0
Expected Memory: < 100 MB
Expected Disk I/O: Maximum read throughput
Expected Network: None
Expected IOPS: 900-1,300
Expected Bandwidth: 3.5-5.5 MB/s
Expected Latency: 800-1,100 μs
Duration: 200-300 seconds (1GB read)
Recovery Time: Immediate

Monitoring Points:
- Disk read IOPS
- Read bandwidth (MB/s)
- Average latency
- Cache hit rates
- Disk utilization

---

Profile 5: iperf3 (Network Test)
Test: iperf3 -c localhost -t 30

Expected CPU Usage: 30-60% (both client and server)
Expected Load Average: 1.0-2.0
Expected Memory: < 100 MB total
Expected Disk I/O: None
Expected Network: Maximum loopback bandwidth
Expected Bandwidth: 20-30 Gbits/sec (loopback)
Expected Retransmissions: < 20
Duration: 30 seconds
Recovery Time: Immediate

Monitoring Points:
- Network bandwidth (Gbits/sec)
- Transfer size (GB)
- Retransmissions
- CPU usage during transfer
- System interrupts

---

Profile 6: nginx (Web Server - Baseline)
Test: ab -n 1000 -c 10 http://localhost/

Expected CPU Usage: 20-40%
Expected Load Average: 0.5-1.0
Expected Memory: 50-100 MB
Expected Disk I/O: Low (static content)
Expected Network: Moderate (HTTP traffic)
Expected Requests/sec: 3,000-5,000
Expected Time/request: 2-4 ms
Expected Failed Requests: 0
Duration: < 1 second for 1000 requests
Recovery Time: Immediate

Monitoring Points:
- Requests per second
- Average response time
- CPU usage during load
- Memory usage
- Active connections

---

Profile 7: nginx (Web Server - High Load)
Test: ab -n 5000 -c 50 http://localhost/

Expected CPU Usage: 50-80%
Expected Load Average: 2.0-4.0
Expected Memory: 100-200 MB
Expected Disk I/O: Low
Expected Network: High (HTTP traffic)
Expected Requests/sec: 3,000-4,000
Expected Time/request: 12-17 ms
Expected Failed Requests: 0
Duration: 1-2 seconds for 5000 requests
Recovery Time: < 2 seconds

Monitoring Points:
- Requests per second under load
- 95th percentile response time
- Maximum response time
- CPU saturation
- Connection handling

================================================================================
DELIVERABLE 4: MONITORING STRATEGY
================================================================================

MONITORING OBJECTIVES
---------------------

1. Capture accurate performance metrics
2. Identify resource bottlenecks
3. Validate expected resource profiles
4. Collect data for optimization
5. Document system behavior under load

MONITORING METHODOLOGY
----------------------

Pre-Test Monitoring:
1. Capture baseline system state
2. Verify no background processes consuming resources
3. Check disk space availability
4. Confirm network connectivity

During-Test Monitoring:
1. Real-time resource observation
2. Continuous metric collection
3. Visual confirmation of expected behavior
4. Early detection of anomalies

Post-Test Monitoring:
1. Verify system recovery to baseline
2. Collect final metrics
3. Archive test results
4. Clean up test artifacts

MONITORING APPROACH PER APPLICATION
------------------------------------

stress-ng (CPU):
Primary Tool: htop (interactive)
Secondary: top, vmstat 1
Commands:
  htop (watch CPU bars)
  vmstat 1 5
  uptime (load average)

Metrics Focus:
- Per-core CPU utilization (%)
- Load average (1/5/15 min)
- Operations per second
- System responsiveness

Monitoring Window: Concurrent with test

---

stress-ng (Memory):
Primary Tool: free -h (repeated)
Secondary: vmstat 1
Commands:
  watch -n 1 free -h
  vmstat 1 5

Metrics Focus:
- Used memory (MB/GB)
- Available memory (MB/GB)
- Swap usage (should be 0)
- Operations per second

Monitoring Window: Concurrent with test

---

fio (Disk I/O):
Primary Tool: iostat -x 1
Secondary: df -h, iotop
Commands:
  iostat -x 1 (during test)
  df -h (before/after)

Metrics Focus:
- IOPS (read/write operations per second)
- Throughput (MB/s or KiB/s)
- Latency (average, p95, p99)
- Disk utilization (%)

Monitoring Window: Concurrent with test
Note: fio provides comprehensive internal metrics

---

iperf3 (Network):
Primary Tool: Built-in iperf3 reporting
Secondary: ss -s, ifstat
Commands:
  ss -s (connection statistics)
  ip -s link (interface statistics)

Metrics Focus:
- Bandwidth (Gbits/sec)
- Transfer size (GB)
- Retransmissions
- CPU usage during transfer

Monitoring Window: iperf3 provides real-time output
Note: Built-in reporting is comprehensive

---

nginx (Web Server):
Primary Tool: Apache Bench (ab) output
Secondary: htop, ss -tuln
Commands:
  htop (during ab test)
  ss -tuln (active connections)

Metrics Focus:
- Requests per second
- Response time (mean, median, percentiles)
- Failed requests
- CPU/memory during load
- Concurrent connections

Monitoring Window: During ab execution
Note: ab provides detailed statistics

REMOTE MONITORING IMPLEMENTATION
---------------------------------

Script: monitor-server.sh (Windows PowerShell)
Purpose: Execute monitoring commands remotely via SSH

Capabilities:
1. System uptime and load
2. CPU usage summary
3. Memory statistics
4. Disk usage
5. Network interface status
6. Process list (top consumers)
7. Service status checks

Usage:
Execute from Windows workstation
Captures snapshot of system state
Can be run before/after tests

Example Commands:
ssh upendra@192.168.56.101 "uptime"
ssh upendra@192.168.56.101 "free -h"
ssh upendra@192.168.56.101 "df -h"
ssh upendra@192.168.56.101 "ps aux --sort=-%cpu | head -n 10"

DATA COLLECTION STRATEGY
-------------------------

Baseline Collection:
Before any performance testing:
- Run: uptime, free -h, df -h, vmstat 1 5, iostat -x 1 5
- Save output as baseline reference
- Document idle resource consumption

Test Execution Collection:
During each test:
- Use appropriate monitoring tool for application
- Capture real-time metrics
- Screenshot key performance indicators
- Note any unexpected behavior

Post-Test Collection:
After each test:
- Capture application-specific metrics
- Verify system returned to baseline
- Document peak resource usage
- Clean up test artifacts (temp files)

Aggregation:
- Compile all metrics into performance table
- Create comparison charts
- Identify bottlenecks
- Document findings

EXPECTED MONITORING SCHEDULE (WEEK 6)
--------------------------------------

Day 1: Baseline and CPU Testing
- Baseline measurements
- stress-ng CPU tests (2 core, 4 core)
- Document CPU performance

Day 2: Memory and Disk Testing
- stress-ng memory tests
- fio write tests
- fio read tests
- fio random tests
- Document memory and I/O performance

Day 3: Network and Web Server Testing
- iperf3 network tests
- nginx baseline tests (low concurrency)
- nginx load tests (high concurrency)
- Document network and server performance

Day 4-5: Optimization and Re-testing
- Apply optimizations
- Re-run key tests
- Compare before/after results
- Document improvements

================================================================================
WEEK 3 LEARNING OUTCOMES
================================================================================

Application Selection Skills:
1. Evaluation of tools for specific testing purposes
2. Understanding of workload characteristics
3. Research of industry-standard benchmarking tools
4. Justification of technical decisions
5. Planning for comprehensive testing coverage

Installation Skills:
1. Remote software installation via SSH
2. APT package manager proficiency
3. Installation verification procedures
4. Dependency management
5. Service configuration (nginx)

Technical Understanding:
1. Different resource consumption patterns
2. CPU vs memory vs I/O vs network workloads
3. Tool capabilities and limitations
4. Monitoring methodology design
5. Performance metric interpretation

Documentation Skills:
1. Detailed application profiles
2. Expected resource usage documentation
3. Installation procedures
4. Test parameter planning
5. Monitoring strategy design

================================================================================
PREPARATION FOR WEEK 4
================================================================================

Security Implementation Tasks:
- SSH key generation on Windows
- Public key transfer to Ubuntu
- SSH configuration hardening
- Firewall rule implementation
- User account creation

Required Before Testing:
All applications installed and verified (✓ COMPLETE)
Monitoring tools ready (✓ COMPLETE)
Baseline system documented (✓ COMPLETE)
Testing methodology defined (✓ COMPLETE)

Security Prerequisites:
Must implement SSH hardening before extensive remote testing
Firewall must be configured for secure access
Non-root user must be created for safe testing

================================================================================
CONCLUSION
================================================================================

Week 3 successfully completed:
✓ 7 applications selected across 5 workload types
✓ All applications installed via SSH
✓ Installation verified with version checks
✓ Expected resource profiles documented
✓ Comprehensive monitoring strategy defined
✓ Ready for security implementation (Week 4)

Application Summary:
- CPU Testing: stress-ng (0.17.06)
- Memory Testing: stress-ng (0.17.06)
- Disk I/O Testing: fio (3.36)
- Network Testing: iperf3 (3.16)
- Server Testing: nginx (1.24.0)
- Monitoring: htop (3.3.0)
- Load Testing: Apache Bench (2.3)

System Status: READY FOR SECURITY CONFIGURATION
Next Phase: Initial Security Configuration (Week 4)

================================================================================
END OF WEEK 3 DOCUMENTATION
================================================================================
EOF
cat week3-documentation.txt