# Encrypted Firebase Configuration

This project uses encrypted Firebase configuration files for security. To set up your development environment, follow these steps:

## Extracting Firebase Configuration Files

1. Install WinRAR if you don't have it already
2. Extract the encrypted configuration files:
   - Right-click on `firebase_config.rar` and select "Extract files..."
   - When prompted, enter the password: `0110`
   - Extract to the project root directory
3. Ensure the following files are placed in their correct locations:
   - `lib/services/firebase_options.dart`
   - `android/app/google-services.json`

## Adding or Updating Firebase Configuration

If you need to update the Firebase configuration:

1. Make your changes to the configuration files
2. Re-create the encrypted archive:
   ```
   "C:\Program Files\WinRAR\WinRAR.exe" a -ep1 -hp0110 firebase_config.rar lib\services\firebase_options.dart android\app\google-services.json
   ```
3. Commit and push the updated `firebase_config.rar` file

## Security Notice

While this approach adds a basic level of security, remember:
- The password is shared among team members
- Don't share the password in public repositories or discussions
- Consider using environment variables or CI/CD secrets for production environments 