#!/usr/bin/bash

# check if the path to the users.txt file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_users.txt>"
    exit 1
fi

INPUT_FILE=$1

# check if the file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi
# check if the file is readable
if [ ! -r "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' is not readable!"
    exit 1
fi
# check if the file is empty
if [ ! -s "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' is empty!"
    exit 1
fi

# Logging setup
LOG_FILE="user_creation.log"
CREDS_FILE="created_users_passwords.txt"
exec > "$LOG_FILE" 2>&1

#logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*"
}

tail -n +2 "$INPUT_FILE" | while IFS=',' read -r username fullname password; do
    
    TEMP_PASS="Temp$(date +%s | sha256sum | base64 | head -c 8)"  # Random 8-char password

    # Create group if it doesn't exist
    if ! getent group "$groupname" > /dev/null; then
        log "Creating group: $groupname"
        sudo groupadd "$groupname"
    fi

    # Create user if it doesn't exist
    if ! id "$username" > /dev/null 2>&1; then
        log "Creating user: $username ($fullname) in group $groupname"
        sudo useradd -m -g "$groupname" -c "$fullname" "$username"

        echo "$username:$TEMP_PASS" | sudo chpasswd
        log "Set temporary password for $username"
        sudo chage -d 0 "$username"

        WELCOME_MSG="/home/$username/WELCOME.txt"
        sudo tee "$WELCOME_MSG" > /dev/null <<EOF
Hello $fullname,

Your account has been created.

Username: $username
Temporary Password: $TEMP_PASS

Please change your password when you log in.

Thank you.
EOF

        sudo chown "$username:$groupname" "$WELCOME_MSG"
        sudo chmod 600 "$WELCOME_MSG"

        echo "$username,$fullname,$TEMP_PASS" >> "$CREDS_FILE"
    else
        log "User $username already exists. Skipping."
    fi
done

chmod 600 "$CREDS_FILE"