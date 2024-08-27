### Challenge: Build a System Monitoring Dashboard

**Description:** Create a script that monitors various system metrics and displays them in a dashboard format. The dashboard should be updated in real-time or at regular intervals and provide a summary of the system's health, including CPU usage, memory usage, disk usage, and network activity.

## Features to Include:

1. **CPU Usage:**
   - Display current CPU usage as a percentage.
   - Show the top 3 processes consuming the most CPU.

2. **Memory Usage:**
   - Display total, used, and available memory.
   - Show the top 3 processes consuming the most memory.

3. **Disk Usage:**
   - Display total, used, and available disk space for mounted filesystems.
   - Highlight filesystems that are above a certain usage threshold (e.g., 80%).

4. **Network Activity:**
   - Display current network upload and download speeds.
   - Show total data sent and received since the script started.

5. **System Uptime:**
   - Display the current system uptime.

6. **Real-Time Updates:**
   - The dashboard should update the displayed information every few seconds.

### Example Dashboard:
```
+------------------------------------------+
|             SYSTEM MONITOR               |
+------------------------------------------+
| CPU Usage: 12%                           |
| Top Processes:                           |
|   1. chrome       25%                    |
|   2. code         15%                    |
|   3. bash          8%                    |
+------------------------------------------+
| Memory Usage: 4.2 GB / 8 GB (52%)        |
| Top Processes:                           |
|   1. chrome      1.2 GB                  |
|   2. code        600 MB                  |
|   3. firefox     300 MB                  |
+------------------------------------------+
| Disk Usage:                              |
| /         40 GB / 50 GB (80%)            |
| /home     30 GB / 100 GB (30%)           |
+------------------------------------------+
| Network:                                 |
| Upload: 120 KB/s  | Download: 300 KB/s   |
| Total Sent: 50 MB | Total Received: 200 MB|
+------------------------------------------+
| Uptime: 3 hours 15 minutes               |
+------------------------------------------+
```

### Extra Challenge:
- Implement an alert system that notifies the user if CPU, memory, or disk usage exceeds a certain threshold.
- Allow the user to save the dashboard's output to a file at regular intervals.

---

This challenge will push you to work with real-time data collection, processing, and display. It also involves using several system commands and possibly handling signals and interruptions. It's a great way to deepen your understanding of system administration and Bash scripting.
