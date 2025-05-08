# Linux IAM Setup Automation

## Overview
This project automates the creation of Linux user accounts and groups from CSV/TXT files, including email notifications and security configurations.

## Features
- Bulk user creation from CSV/TXT files
- Automatic group creation and assignment
- Temporary password generation with complexity requirements
- Force password change on first login
- Welcome message creation for each user
- Email notifications to new users
- Detailed logging of all operations
- Secure storage of credentials (Only accessible by root user)

## Prerequisites
- Linux system with sudo privileges
- `curl` for email notifications
- Mail utilities
- Bash shell

## File Structure
```
.
├── am_setup.sh         # Main IAM setup script
├── csv_users.csv       # Sample CSV input file
├── mailtest.sh        # Email testing utility
├── users.txt          # Sample TXT input file
└── .gitignore        # Git ignore configuration
```

## Input File Format
The script accepts both CSV and TXT files with the following format:
```csv
username,fullname,group,email
jdoe,John Doe,engineering,jdoe@example.com
```

## Usage
1. Run the setup script with an input file:
```bash
./am_setup.sh users.txt
# or
./am_setup.sh csv_users.csv
```

2. Test email functionality:
```bash
./mailtest.sh recipient@example.com "Subject" "Email body"
```

## Security Features
- Password complexity enforcement
- Home directory permissions set to 700
- Welcome message file permissions set to 600
- Credentials file access restricted
- Forced password change on first login

## Generated Files
- `iam_setup.log`: Detailed operation logs
- `created_users_passwords.txt`: Secure storage of credentials
- `WELCOME.txt`: Created in each user's home directory

## Email Notifications
Users receive emails containing:
- Username
- Temporary password
- Login instructions
- Password change requirement notice

## Error Handling
- Input file validation
- File permissions checking
- Empty file detection
- User/group existence verification
