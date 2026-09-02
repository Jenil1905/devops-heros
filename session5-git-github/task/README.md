# Session 5: Git Homework Tasks

This document contains step-by-step execution logs, command outputs, and detailed explanations for **Task 1** (`git commit -a -m` vs `git commit -m`) and **Task 2** (`git cherry-pick`).

---

## Task 1: `git commit -a -m` vs `git commit -m`

### Objective
Understand and demonstrate the operational difference between `git commit -m` and `git commit -a -m`.

### Theoretical Difference
- **`git commit -m "message"`**: Only commits changes that have already been explicitly added to the Git staging index using `git add`. Any modified tracked files or untracked new files that were not staged are excluded from the commit.
- **`git commit -a -m "message"`**: Automatically stages and commits all **tracked** files that have been modified or deleted. However, it will **NOT** stage or commit **untracked** (newly created) files.

---

### Execution & Test Output

#### 1. Initial File Setup
```bash
$ echo "Hello Initial File" > file1.txt
$ git add file1.txt
$ git commit -m "Initial commit: create file1.txt"
[main (root-commit) f174362] Initial commit: create file1.txt
 1 file changed, 1 insertion(+)
 create mode 100644 file1.txt
```

#### 2. Modifying Tracked File & Creating Untracked File
```bash
$ echo "Updated content in file1" >> file1.txt
$ echo "This is untracked file2" > file2.txt
$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
        modified:   file1.txt

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        file2.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

#### 3. Testing `git commit -m` (Without `git add`)
```bash
$ git commit -m "Attempt commit without git add"
On branch main
Changes not staged for commit:
        modified:   file1.txt

Untracked files:
        file2.txt

no changes added to commit (use "git add" and/or "git commit -a")
```
**Observation**: `git commit -m` failed because modified changes in `file1.txt` were not added to the staging area.

#### 4. Testing `git commit -a -m`
```bash
$ git commit -a -m "Commit tracked modified files using git commit -a -m"
[main 370b78a] Commit tracked modified files using git commit -a -m
 1 file changed, 1 insertion(+)

$ git status
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        file2.txt

nothing added to commit but untracked files present (use "git add" to track)
```
**Observation**: `git commit -a -m` automatically staged and committed the modified **tracked** file (`file1.txt`). The **untracked** file (`file2.txt`) was ignored and remained untracked.

---

## Task 2: Git Cherry-Pick

### Objective
Demonstrate cherry-picking a specific commit from a feature branch into the `main` branch.

---

### Step-by-Step Execution Logs

#### 1. Commits on `main` Branch
```bash
$ git add file2.txt && git commit -m "Add file2.txt to main branch"
[main 854d930] Add file2.txt to main branch

$ echo "Main branch feature" > main_feature.txt
$ git add main_feature.txt && git commit -m "Main commit 4: Add main_feature.txt"
[main cdc5f35] Main commit 4: Add main_feature.txt

$ git log --oneline
cdc5f35 (HEAD -> main) Main commit 4: Add main_feature.txt
854d930 Add file2.txt to main branch
370b78a Commit tracked modified files using git commit -a -m
f174362 Initial commit: create file1.txt
```

#### 2. Creating New Branch & Making Commits
```bash
$ git checkout -b feature-branch
Switched to a new branch 'feature-branch'

$ echo "Feature component 1" > feature1.txt && git add feature1.txt && git commit -m "Feature commit 1: Add feature1.txt"
[feature-branch 1ad01ba] Feature commit 1: Add feature1.txt

$ echo "Feature component 2 - Target Cherry Pick" > feature2.txt && git add feature2.txt && git commit -m "Feature commit 2: Add feature2.txt"
[feature-branch d8d5552] Feature commit 2: Add feature2.txt

$ echo "Feature component 3" > feature3.txt && git add feature3.txt && git commit -m "Feature commit 3: Add feature3.txt"
[feature-branch 1275418] Feature commit 3: Add feature3.txt
```

#### 3. Identifying Specific Commit Hash via `git log`
```bash
$ git log --oneline
1275418 (HEAD -> feature-branch) Feature commit 3: Add feature3.txt
d8d5552 Feature commit 2: Add feature2.txt
1ad01ba Feature commit 1: Add feature1.txt
cdc5f35 (main) Main commit 4: Add main_feature.txt
854d930 Add file2.txt to main branch
370b78a Commit tracked modified files using git commit -a -m
f174362 Initial commit: create file1.txt
```
Target Commit Hash to Cherry-Pick: **`d8d5552`** (`Feature commit 2: Add feature2.txt`)

#### 4. Switching to `main` and Executing `git cherry-pick`
```bash
$ git checkout main
Switched to branch 'main'

$ git cherry-pick d8d5552
[main 13574fa] Feature commit 2: Add feature2.txt
 Date: Wed Sep 2 23:37:12 2026 +0530
 1 file changed, 1 insertion(+)
 create mode 100644 feature2.txt
```

#### 5. Verification on `main` Branch
```bash
$ git log --oneline
13574fa (HEAD -> main) Feature commit 2: Add feature2.txt
cdc5f35 Main commit 4: Add main_feature.txt
854d930 Add file2.txt to main branch
370b78a Commit tracked modified files using git commit -a -m
f174362 Initial commit: create file1.txt

$ ls -la
total 28
drwxrwxr-x 3 jenil jenil 4096 Sep  2 23:37 .
drwxrwxr-x 3 jenil jenil 4096 Sep  2 23:36 ..
-rw-rw-r-- 1 jenil jenil   41 Sep  2 23:37 feature2.txt
-rw-rw-r-- 1 jenil jenil   44 Sep  2 23:36 file1.txt
-rw-rw-r-- 1 jenil jenil   24 Sep  2 23:36 file2.txt
-rw-rw-r-- 1 jenil jenil   20 Sep  2 23:37 main_feature.txt
```

**Verification Result**:
- `feature2.txt` from commit `d8d5552` is now successfully cherry-picked and available on `main` branch.
- `feature1.txt` and `feature3.txt` were **not** merged into `main`, demonstrating selective commit cherry-picking.
