....

def compress_and_upload_symbols(ndk_path, symbols_path, sentry_cli_path, org, project, auth_token):
    # Construct the paths for the source and compressed files
    source_file = os.path.join(symbols_path, "libUnreal.so")
    compressed_file = os.path.join(symbols_path, "compressed_libUnreal.so")

    # Compress the symbols using llvm-objcopy
    compression_command = [
        os.path.join(ndk_path, 'llvm-objcopy.exe'),
        '--compress-debug-sections',
        source_file,
        compressed_file
    ]
    print("Compressing symbols...")
    subprocess.run(compression_command, check=True)

    # Upload the compressed symbols to Sentry
    upload_command = [
        sentry_cli_path,
        'upload-dif',
        '-o', org,
        '-p', project,
        '--auth-token', auth_token,
        compressed_file
    ]
    print("Uploading symbols to Sentry...")
    subprocess.run(upload_command, check=True)

def find_sentry_cli():
    sentry_cli_path = os.getenv("SENTRY_CLI_PATH")
    if not sentry_cli_path:
        project_dir = find_project_dir()
        sentry_cli_path = os.path.join(project_dir, 'Plugins', 'Sentry', 'Source', 'ThirdParty', 'CLI', 'sentry-cli-Windows-x86_64.exe')
    if not os.path.exists(sentry_cli_path):
        print("sentry-cli executable not found at: {}".format(sentry_cli_path))  # Debugging output
        sys.exit(1)
    return sentry_cli_path

# other code below relating to building package and uplaod of the game.
....
