---
id: 1257
title: 'Git : How to Split Sub-Directory to Separate Repository'
date: '2019-09-15T13:30:58-07:00'
author: saurzcode

guid: 'https://saurzcode.in//?p=1257'
permalink: /2019/09/git-how-to-split-subdirectory-to-separate-repository/
meta-checkbox:
    - ''
dsq_thread_id:
    - '1234567890'
categories:
    - 'Git'
    - 'Repository'
    - 'Tools'
tags:
    - git
    - repository
    - split
---

# GIT Split Sub-Directory to Repositories

If you regret putting that git sub-directory inside a git repository and thinking about moving it out of the current repository to its own repository, you have come to the right place!

In this post, we will see step by step approach to give a new home to that git sub-directory. I know the biggest worry when we are trying to do something like this is, if you will be able to get all the history of commits, all branches, tags, etc. intact while migrating the sub-directory. Don't worry about that! This post got you covered.

Below, I will provide you with 2 approaches, first, *to move the sub-directory along with all the commits with all its branches and tags* and second, *to move just with commit history to master*, if you don't care about the branches. Let's get started -

For both the steps below let's assume following tree structure of folders that exists:

- **Original repository with subdirectories:** `https://github.com/USER/REPOSITORY-A.GIT`
- **Sub-directory to be migrated to the new repository:** `folder-b`

![git sub-directory structure]({{site.baseurl}}/assets/uploads/2019/09/Screenshot-2019-09-15-at-2.05.39-PM.png)

## Approach#1 - Moving along with branches and tags and commit history.

**Step 1.** Go to the directory where you want to create a new repository.

```sh
cd source-code
```

**Step 2.** Clone the original repository to a folder named after the new repository.

```sh
git clone https://github.com/USER/REPOSITORY-A.GIT REPOSITORY-B
```

**Step 3.** Go to the directory which got created when you cloned the repository above. REPOSITORY-B

```sh
cd REPOSITORY-B
```

**Step 4.** Filter out and keep only the commits and branches for the FOLDER using git filter-branch command.

```sh
git filter-branch --prune-empty FOLDER-B -- --all
```

you can either decide to keep all branches and tags using --all or you can specify a branch name in that place.

**Step 5.** Now, REPOSITORY-A directory only contains the sub-directory and files within it.

**Step 6.** Create a new repository on git, let's say: `https://github.com/USER/REPOSITORY-B.GIT`

**Step 7.** Set remote for the current folder as a new repository -

```sh
git remote set-url origin https://github.com/USER/REPOSITORY-B.GIT
```

**Step 8.** Verify the remote

```sh
git remote -v
```

**Step 9.** Push all changes to remote -

```sh
git push -u origin --all
```

## Approach#2 - Moving only with commit history to a master branch in a new repository

**Step 1.** First, go to the folder for your old repository, you split a new branch from your history containing only the subtree rooted at the *folder-b*. Read more about *git subtree* command [here](https://git-memo.readthedocs.io/en/latest/subtree.html).

```sh
cd repository-a
git subtree split -P folder-b  -b folder-b-only
```

**Step 2.** Next, create a folder named after the new repository

```sh
mkdir repository-b; cd repository_b
```

**Step 3.** Initialize and import the newly created branch in the old repository to the current folder - *repository-b*

```sh
git init; git pull ~/source-code/repository-a folder-b-only
```

**Step 4.** Now, Lets, Create new repository *repository-b* and add as the *origin* to the current folder.

```sh
git remote add origin https://github.com/USER/REPOSITORY-B.GIT
```

**Step 5.** Push to *master*

```sh
git push origin -u master
```

**Step 6.** In the end, just remove the *folder-b* from the original repository using *git rm -rf*

```sh
git rm -rf folder-b
```

Please comment below, If you face any issues or if you have any questions on above!

---

**References:**
- [https://stackoverflow.com/questions/359424/detach-move-subdirectory-into-separate-git-repository](https://stackoverflow.com/questions/359424/detach-move-subdirectory-into-separate-git-repository)
- [https://help.github.com/en/articles/splitting-a-subfolder-out-into-a-new-repository](https://help.github.com/en/articles/splitting-a-subfolder-out-into-a-new-repository)