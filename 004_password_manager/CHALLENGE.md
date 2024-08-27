# Challenge: Build a Simple Password Manager with Bash

**Description:** Create a Bash script that functions as a simple password manager. The script should be able to store, display, and delete passwords, as well as generate random strong passwords. All passwords should be stored encrypted in a text file, and the user should be able to decrypt them as needed by providing a master password.

## Features to Include:

1. **Create New Password:**
   - Allow the user to enter a service name (e.g., "Gmail") and either a custom password or generate a strong password automatically.
   - The password should be encrypted and stored in a text file (e.g., `passwords.txt`) along with the service name.

2. **View Password:**
   - Require the user to enter a master password to decrypt and display a selected password.

3. **Delete Password:**
   - Allow the user to delete a password from the list.

4. **Generate Strong Password:**
   - Implement a function to generate strong passwords, consisting of a mix of uppercase and lowercase letters, numbers, and special characters.

5. **Save and Read Passwords:**
   - Passwords should be saved encrypted in a text file. They should be decrypted when displayed.

6. **Log Activities:**
   - All changes (creating, viewing, deleting) should be logged in a log file (e.g., `password_log.txt`) with a timestamp.

### Example Format in the Text File:
- **Gmail | e3v2m7ks! | Encrypted**
- **Dropbox | HZ8#4h$s | Encrypted**

### Example Main Menu:
```
1) Add New Password
2) View Password
3) Delete Password
4) Generate Strong Password
5) Exit
```

### Encryption Tips:
You can use tools like `openssl` or `gpg` to encrypt and decrypt passwords.

### Extra Challenge:
Implement a function that checks the strength of the user's password based on length, character variety, and whether it contains words from a dictionary.

---

Good luck with your password manager! This project will challenge you to work with security features, file handling, and user interaction in Bash.
