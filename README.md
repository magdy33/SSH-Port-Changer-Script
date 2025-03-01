# SSH Port Changer Script

## Description

This Bash script is designed to change the SSH port in the `sshd_config` file, configure firewall rules, update SELinux policies (if enabled), and restart the SSH service to apply the changes.

## Author

**Magdi**


---

## Features

- Allows changing the SSH port via command-line arguments.
- Creates a backup of the `sshd_config` file before modifying it.
- Updates firewall rules (supports `firewalld` and `UFW`).
- Configures SELinux policies if enforced.
- Restarts the SSH service after making changes.
- Displays the new SSH port for confirmation.

---

## Usage

Run the script with the following options:

```bash
./ssh_port_changer.sh [-p port_number] [-h]
```

### Options:

- `-p PORT` : Specify the new SSH port (default is `9999`).
- `-h` : Show the help message and exit.

### Example Usage

To change the SSH port to `2222`:

```bash
./ssh_port_changer.sh -p 2222
```

If no port is specified, it defaults to `9999`:

```bash
./ssh_port_changer.sh
```

---

## Firewall Configuration

The script automatically updates the firewall:

- If `firewalld` is installed, it adds the new port and reloads the rules.
- If `UFW` is installed, it allows the new port and reloads the firewall.
- If no firewall is detected, a warning is displayed to configure it manually.

---

## SELinux Configuration

If SELinux is in **Enforcing** mode, the script updates SELinux policies to allow the new SSH port.

---

## Notes

- **Run the script as root** to modify system configurations.
- **Ensure to update firewall rules** before restarting SSH to avoid being locked out.
- After the script runs, verify the new SSH port with:
  ```bash
  sudo sshd -T | grep "port"
  ```

---

## Troubleshooting

- If SSH fails to restart, check logs using:
  ```bash
  sudo journalctl -xe
  ```
- If locked out after changing the port, use console access to revert changes.

---

