# Lima Dev Environment

## TL;DR

This repository provides a **Lima**-based development environment for setting up a fully configured Linux virtual machine (VM) with Docker, ASDF, NeoVim, and other essential tools. Lima is a lightweight VM manager that simplifies the process of running Linux VMs on macOS with features like **automatic port mapping**, **file sharing**, and **seamless integration** with your host system.

### Key Features of Lima:
- **Automatic Port Mapping**: Lima automatically forwards ports from the VM to your host, making it easy to access services running inside the VM.
- **File Sharing**: Share files between your host and the VM effortlessly.
- **Lightweight**: Lima is designed to be fast and resource-efficient.
- **Easy Configuration**: Configure your VM using a simple YAML file.

### Flow of Execution:
1. **Provision**: Set up the Lima VM using the provided configuration.
2. **Shell**: Access the VM shell to run commands inside the VM.
3. **Run Root Provision**: Execute the root provisioning script to install system-wide dependencies and configure the environment.
4. **Run User Provision**: Execute the user provisioning script to install user-specific tools and configurations.

---

## Getting Started

### Prerequisites
- macOS (Lima is designed for macOS)
- [Lima](https://github.com/lima-vm/lima) installed on your system

### Installation

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/yourusername/lima-dev-env.git
   cd lima-dev-env
   ```

2. **Start the Lima VM**:
   ```sh
   lima start
   ```
   This will create and start a VM based on the configuration provided in the repository.

3. **Access the VM Shell**:
   ```sh
   lima shell
   ```
   This will drop you into a shell inside the VM.

4. **Run Root Provisioning**:
   ```sh
   sudo /bin/bash /path/to/bin/provision-root.sh
   ```
   This script installs system-wide dependencies like Docker, Python, Zsh, and NeoVim.

5. **Run User Provisioning**:
   ```sh
   /bin/bash /path/to/bin/provision-user.sh
   ```
   This script sets up user-specific tools like ASDF, Node.js, Java, Python, and Oh My Zsh.

---

## Features

### Automatic Port Mapping
Lima automatically maps ports from the VM to your host, so you can access services running inside the VM as if they were running locally. For example, if you run a web server on port `8080` inside the VM, it will be accessible at `http://localhost:8080` on your host.

### File Sharing
Lima allows you to share files between your host and the VM. This makes it easy to work on projects stored on your host while running tools inside the VM.

### Pre-Configured Tools
This repository includes scripts to install and configure:
- **Docker**: For containerization and development.
- **ASDF**: A version manager for multiple programming languages.
- **NeoVim**: A modern, extensible text editor.
- **Zsh**: A powerful shell with Oh My Zsh for enhanced productivity.
- **Node.js, Java, Python**: Popular programming languages and their ecosystems.

---

## Configuration

### Lima Configuration
The Lima VM is configured using a YAML file. You can customize the VM settings by editing the configuration file. Key settings include:
- **CPU and Memory**: Allocate resources to the VM.
- **Port Forwarding**: Configure which ports are forwarded to the host.
- **File Sharing**: Define directories to share between the host and VM.

### Provisioning Scripts
- **`bin/provision-root.sh`**: Installs system-wide dependencies and configures the environment. This script must be run with `sudo`.
- **`bin/provision-user.sh`**: Sets up user-specific tools and configurations. This script should be run as the current user.

---

## Usage

### Starting the VM
To start the VM, run:
```sh
lima start
```

### Accessing the VM
To access the VM shell, run:
```sh
lima shell
```

### Stopping the VM
To stop the VM, run:
```sh
lima stop
```

### Restarting the VM
To restart the VM, run:
```sh
lima restart
```

---

## Customization

### Adding New Tools
To add new tools to the environment:
1. Edit the appropriate provisioning script (`provision-root.sh` for system-wide tools or `provision-user.sh` for user-specific tools).
2. Add commands to install and configure the tool.
3. Re-run the provisioning script to apply the changes.

### Modifying Lima Configuration
To modify the Lima VM configuration:
1. Edit the Lima YAML configuration file.
2. Restart the VM to apply the changes:
   ```sh
   lima restart
   ```

---

## Troubleshooting

### Common Issues
- **Port Conflicts**: If a port is already in use on your host, Lima will not be able to forward it. Ensure the port is free or configure Lima to use a different port.
- **File Sharing Permissions**: Ensure the directories you want to share have the correct permissions.
- **Provisioning Errors**: If a provisioning script fails, check the error message and ensure all dependencies are installed.
- **SSH Key Not Forwarded**: Run `ssh-agent` and `ssh-add` to forward your SSH key:

### Debugging
To debug issues with the VM, you can:
- Check the Lima logs:
  ```sh
  lima logs
  ```
- Access the VM shell and run commands manually:
  ```sh
  lima shell
  ```

---

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
