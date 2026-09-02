# Linux Homework Tasks

## Task 1: Soft Links and Hard Links

### What is a Link in Linux?

A link is a way to provide another reference or path to a file.

Linux mainly provides two types of links:

1. Hard Links
2. Soft Links (Symbolic Links)

---

## Hard Link

A hard link is another name or reference to the same file data.

Both the original file and the hard link point to the same inode.

### Create a Hard Link

```bash
ln original_file hard_link
```

### Example

```bash
touch file1.txt

ln file1.txt hardlink.txt
```

Check the inode numbers:

```bash
ls -li
```

Both files should have the same inode number.

### Important Characteristics

- Hard links point directly to the inode.
- Original file and hard link share the same data.
- Deleting the original file does not delete the data if a hard link still exists.
- Hard links cannot normally be created for directories.
- Hard links cannot cross different file systems.

### Delete a Hard Link

```bash
rm hardlink.txt
```

---

## Soft Link (Symbolic Link)

A soft link is a special file that stores the path to another file.

It works similarly to a shortcut in other operating systems.

### Create a Soft Link

```bash
ln -s original_file soft_link
```

### Example

```bash
touch file1.txt

ln -s file1.txt softlink.txt
```

Check the files:

```bash
ls -li
```

The soft link will have a different inode number.

### Important Characteristics

- Soft links store the path to the original file.
- They can link to directories.
- They can cross different file systems.
- If the original file is deleted, the soft link becomes broken.

### Delete a Soft Link

```bash
rm softlink.txt
```

---

## Practical Example

```bash
# Create a file
echo "Hello Linux" > original.txt

# Create a hard link
ln original.txt hardlink.txt

# Create a soft link
ln -s original.txt softlink.txt

# Check inode numbers
ls -li

# Delete the original file
rm original.txt

# Check the hard link
cat hardlink.txt

# Check the soft link
cat softlink.txt
```

The hard link will still contain the data, while the soft link will become broken.

---

## Soft Link vs Hard Link

| Feature | Hard Link | Soft Link |
|---|---|---|
| Points to | Inode/Data | File Path |
| Same inode | Yes | No |
| Works across file systems | No | Yes |
| Can link directories | Normally No | Yes |
| Survives deletion of original file | Yes | No |
| Command | `ln file link` | `ln -s file link` |

---

## Interview Question

### What is the difference between a soft link and a hard link?

A hard link directly points to the inode of a file, meaning multiple filenames can reference the same data. Even if the original filename is deleted, the data remains accessible through the hard link.

A soft link stores the path to another file. If the original file is deleted or moved, the soft link becomes broken.

---

# Task 2: adduser vs useradd

Linux provides two commonly used commands for creating users:

```bash
adduser
```

and

```bash
useradd
```

Although both are used to create users, they work differently.

---

## useradd

`useradd` is a low-level Linux command used to create users.

Example:

```bash
sudo useradd testuser
```

By itself, it may create only the user account without creating a home directory or setting a password.

Additional options are often required:

```bash
sudo useradd -m -s /bin/bash testuser
```

Here:

- `-m` creates a home directory.
- `-s` specifies the user's login shell.

---

## adduser

`adduser` is a higher-level and more user-friendly command, commonly used on Debian and Ubuntu systems.

Example:

```bash
sudo adduser testuser
```

It usually:

- Creates the user.
- Creates a home directory.
- Sets up default configuration files.
- Prompts for a password.
- Interactively asks for user information.

---

## adduser vs useradd

| Feature | adduser | useradd |
|---|---|---|
| Type | High-level script | Low-level binary |
| Interactive | Yes | No |
| Creates home directory automatically | Usually Yes | Requires options depending on configuration |
| Easier for beginners | Yes | No |
| Commonly preferred on Ubuntu | Yes | Less commonly for manual user creation |

---

## Recommended Command on Ubuntu

On Ubuntu and Debian-based systems, `adduser` is generally preferred for manually creating users because it is interactive and automatically performs common setup tasks.

### Create a Test User

```bash
sudo adduser testuser
```

Verify the user:

```bash
id testuser
```

Check the home directory:

```bash
ls /home
```

---

## Interview Question

### What is the difference between adduser and useradd?

`useradd` is a low-level command for creating users and usually requires additional options to configure the user account.

`adduser` is a higher-level interactive script that simplifies user creation by automatically creating a home directory and prompting for a password and other details.

On Ubuntu, `adduser` is generally more convenient for manually creating users.

---

# Task 3: journalctl

## What is journalctl?

`journalctl` is a command used to view logs collected by the `systemd` journal.

It allows administrators to inspect:

- System logs
- Kernel logs
- Service logs
- Boot logs
- Authentication-related events

---

## View All Logs

```bash
journalctl
```

---

## View Recent Logs

```bash
journalctl -e
```

This jumps to the end of the logs.

---

## Follow Logs in Real Time

```bash
journalctl -f
```

This works similarly to:

```bash
tail -f
```

---

## View Logs for a Specific Service

The `-u` option is used to view logs for a specific systemd service.

Example:

```bash
journalctl -u ssh
```

On some Ubuntu systems, the SSH service may be named:

```bash
journalctl -u ssh.service
```

---

## Follow Logs for a Service

```bash
journalctl -u ssh -f
```

This allows you to monitor new logs generated by the SSH service.

---

## View Logs From the Current Boot

```bash
journalctl -b
```

This is useful when troubleshooting problems that occurred after the current system boot.

---

## View Logs Since a Specific Time

```bash
journalctl --since "1 hour ago"
```

Example:

```bash
journalctl --since today
```

---

## Practical Service Log Check

Check the status of a service:

```bash
systemctl status ssh
```

Then view its logs:

```bash
journalctl -u ssh
```

To follow logs in real time:

```bash
journalctl -u ssh -f
```

---

## Interview Question

### What is journalctl used for?

`journalctl` is used to query and view logs collected by the systemd journal. It helps administrators troubleshoot system problems, inspect service logs, view boot logs, and monitor logs in real time.

---

# Task 4: Important Linux Commands

## File and Directory Commands

### pwd

Shows the current working directory.

```bash
pwd
```

---

### ls

Lists files and directories.

```bash
ls
```

Useful options:

```bash
ls -l
ls -a
ls -la
```

---

### cd

Changes the current directory.

```bash
cd directory_name
```

Go to the home directory:

```bash
cd
```

Go to the parent directory:

```bash
cd ..
```

---

### mkdir

Creates a directory.

```bash
mkdir test
```

Create nested directories:

```bash
mkdir -p parent/child
```

---

### touch

Creates an empty file.

```bash
touch file.txt
```

---

### cp

Copies files or directories.

```bash
cp file.txt backup.txt
```

Copy a directory:

```bash
cp -r directory1 directory2
```

---

### mv

Moves or renames files.

```bash
mv old.txt new.txt
```

---

### rm

Removes files.

```bash
rm file.txt
```

Remove a directory:

```bash
rm -r directory
```

Use this command carefully.

---

# Viewing File Contents

### cat

Displays the contents of a file.

```bash
cat file.txt
```

---

### less

Views a file page by page.

```bash
less file.txt
```

Press `q` to exit.

---

### head

Displays the first lines of a file.

```bash
head file.txt
```

Specify the number of lines:

```bash
head -n 20 file.txt
```

---

### tail

Displays the last lines of a file.

```bash
tail file.txt
```

Follow a file in real time:

```bash
tail -f file.txt
```

---

# Searching Commands

### grep

Searches for text inside files.

```bash
grep "error" file.txt
```

Case-insensitive search:

```bash
grep -i "error" file.txt
```

---

### find

Searches for files and directories.

```bash
find /home -name file.txt
```

---

### which

Shows the location of an executable command.

```bash
which python
```

---

# File Permissions

### chmod

Changes file permissions.

```bash
chmod 755 script.sh
```

---

### chown

Changes the owner of a file.

```bash
sudo chown user:user file.txt
```

---

# User Information

### whoami

Shows the current user.

```bash
whoami
```

---

### id

Displays user and group information.

```bash
id
```

---

### passwd

Changes a user's password.

```bash
passwd
```

---

# Process Commands

### ps

Displays running processes.

```bash
ps
```

View all processes:

```bash
ps aux
```

---

### top

Displays running processes and system resource usage.

```bash
top
```

---

### kill

Terminates a process using its Process ID (PID).

```bash
kill PID
```

---

# System Information

### uname

Displays system information.

```bash
uname -a
```

---

### df

Shows disk space usage.

```bash
df -h
```

---

### free

Shows memory usage.

```bash
free -h
```

---

### uptime

Shows how long the system has been running.

```bash
uptime
```

---

# Networking Commands

### ping

Tests network connectivity.

```bash
ping google.com
```

---

### ip

Displays network interface information.

```bash
ip addr
```

---

### curl

Transfers data from or to a server.

```bash
curl example.com
```

---

# Package Management on Ubuntu

### apt update

Updates the package list.

```bash
sudo apt update
```

---

### apt upgrade

Upgrades installed packages.

```bash
sudo apt upgrade
```

---

### apt install

Installs a package.

```bash
sudo apt install package_name
```

---

# Conclusion

Through these tasks, I learned about important Linux concepts and commands used in system administration.

Key learning outcomes include:

- Understanding the difference between hard links and soft links.
- Creating and deleting different types of links.
- Understanding the difference between `adduser` and `useradd`.
- Creating users in Ubuntu.
- Using `journalctl` to inspect system and service logs.
- Understanding commonly used Linux commands for files, directories, processes, permissions, networking, and system administration.
