#!/usr/bin/env python3

import time
import os
import sys
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import git

# Customize these paths
REPO_PATH = os.path.abspath(".")
LOG_FILE = os.path.join(REPO_PATH, "copilot_suggestions.log")
WATCH_DIRS = [os.path.join(REPO_PATH, "src")]  # Update to your code folder(s)


class CodeChangeHandler(FileSystemEventHandler):
    def __init__(self, repo):
        super().__init__()
        self.repo = repo
    
    def on_modified(self, event):
        if event.is_directory:
            return
        
        # Only track .py, .js, .ts, .java, etc. (customize as needed)
        if not event.src_path.endswith((".py", ".js", ".ts", ".java", ".go", ".rs")):
            return
        
        # Fetch changes
        self.log_new_lines()

    def log_new_lines(self):
        # We'll look at the index to see what is staged vs. unstaged
        # For this simple approach, let's just look at the full diff.
        diff = self.repo.git.diff("HEAD")
        
        # Filter lines that are newly added
        added_lines = []
        for line in diff.splitlines():
            if line.startswith('+') and not line.startswith('+++'):
                # Exclude the Git diff metadata lines like '+++ b/file.py'
                added_lines.append(line[1:])  # Remove the leading '+'
        
        if added_lines:
            with open(LOG_FILE, "a") as f:
                f.write(f"--- New lines at {time.ctime()} ---\n")
                for l in added_lines:
                    f.write(l + "\n")
                f.write("\n")

def main():
    repo = git.Repo(REPO_PATH)
    event_handler = CodeChangeHandler(repo)
    observer = Observer()
    
    for directory in WATCH_DIRS:
        observer.schedule(event_handler, path=directory, recursive=True)
    
    observer.start()
    print(f"Watching directories: {WATCH_DIRS}")
    print(f"Logging new lines to: {LOG_FILE}")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    
    observer.join()

if __name__ == "__main__":
    main()
