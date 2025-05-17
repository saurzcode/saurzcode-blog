---
id: 1257
title: 'Git &#8211; How to Split Subdirectory to Separate Repository'
date: '2019-09-15T14:57:26-07:00'
author: saurzcode
layout: post
guid: 'https://saurzcode.in/?p=1257'
permalink: /2019/09/git-how-to-split-subdirectory-to-separate-repository/
meta-checkbox:
    - ''
classic-editor-remember:
    - block-editor
image: /wp-content/uploads/2019/09/download-e1598944084944.png
categories:
    - git
    - Technology
tags:
    - git
    - 'git sub-directory'
    - 'git subdirectory'
    - 'git subtree'
---

<!-- wp:jetpack/markdown {"source":"# GIT Split Sub-Directory to Repositories"} -->
<div class="wp-block-jetpack-markdown"><h1>GIT Split Sub-Directory to Repositories</h1>
</div>
<!-- /wp:jetpack/markdown -->

<!-- wp:paragraph -->
<p>If you regret putting that git sub-directory inside a git repository and thinking about moving it out of the current repository to its own repository, you have come to the right place!</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>In this post, we will see step by step approach to give a new home to that git sub-directory. I know the biggest worry when we are trying to do something like this is, if you will be able to get all the history of commits, all branches, tags, etc. intact while migrating the sub-directory. Don't worry about that! This post got you covered.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Below, I will provide you with 2 approaches, first,&nbsp;&nbsp;<em>to move the sub-directory along with all the commits with all its branches and tags</em> and second,&nbsp;&nbsp;<em>to move just with commit history to master</em>&nbsp;, if you don't care about the branches. Let's get started -</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>For both the steps below let's assume following tree structure of folders that exists&nbsp; -</p>
<!-- /wp:paragraph -->

<!-- wp:more -->
<!--more-->
<!-- /wp:more -->

<!-- wp:list -->
<ul><li><em>Original repository with subdirectories - <span style="color: #993366;">https://github.com/USER/REPOSITORY-A.GIT</span></em></li><li><em>Sub-directory to be migrated to the new repository</em> - <span style="color: #993366;"><em>folder-b</em></span></li></ul>
<!-- /wp:list -->

<!-- wp:image {"align":"center","id":1259,"className":"wp-image-1259"} -->
<div class="wp-block-image wp-image-1259"><figure class="aligncenter"><img src="http://saurzcode.in/wp-content/uploads/2019/09/Screenshot-2019-09-15-at-2.05.39-PM.png" alt="" class="wp-image-1259"/><figcaption>git sub-directory structure</figcaption></figure></div>
<!-- /wp:image -->

<!-- wp:heading -->
<h2>Approach#1 - Moving along with branches and tags and commit history.</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p><strong>Step 1.</strong> Go to the directory where you want to create a new repository.</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">cd source-code</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 2.</strong> Clone the original repository to a folder named after the new repository.</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">git clone&nbsp;https://github.com/USER/REPOSITORY-A.GIT REPOSITORY-B</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 3.</strong> Go to the directory which got created when you cloned the repository above. REPOSITORY-B</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">cd REPOSITORY-B</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 4.</strong> Filter out and keep only the commits and branches for the FOLDER using git filter-branch command.</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">git filter-branch --prune-empty FOLDER-B -- --all</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>you can either decide to keep all branches and tags using --all or you can specify a branch name in that place.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Step 5.</strong>&nbsp;Now, REPOSITORY-A directory only contains the sub-directory and files within it.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Step 6.</strong> Create a new repository on git, let's say -&nbsp;&nbsp;<span style="color: #993366;">https://github.com/USER/REPOSITORY-B.GIT</span></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Step 7.</strong> Set remote for the current folder as a new repository -</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">git remote set-url origin https://github.com/USER/REPOSITORY-B.GIT</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 8.</strong> Verify the remote</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">git remote -v</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 9.</strong> Push all changes to remote -</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">git push -u origin --all</pre>
<!-- /wp:preformatted -->

<!-- wp:heading -->
<h2>&nbsp;</h2>
<!-- /wp:heading -->

<!-- wp:heading -->
<h2>Approach#2 -Moving only with commit history to a master branch in a new repository</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p><strong>Step 1</strong>.&nbsp;First, go to the folder for your old repository, you split a new branch from your history containing only the subtree rooted at the <em>folder-b</em>. Read more about <em>git subtree</em> command <a href="https://git-memo.readthedocs.io/en/latest/subtree.html">here</a>.</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">cd repository-a
git subtree split -P folder-b  -b folder-b-only</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 2.</strong>&nbsp;Next, create a folder named after the new repository</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">mkdir repository-b; cd repository_b</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 3.</strong> Initialize and import the newly created branch in the old repository to the current folder - <em>repository-b</em></p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">git init; git pull ~/source-code/repository-a folder-b-only</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 4.</strong>&nbsp;Now, Lets, Create new repository <em>repository-b</em> and add as the <em>origin</em> to the current folder.</p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">git remote add origin https://github.com/USER/REPOSITORY-B.GIT</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 5</strong>. Push to <em>master</em></p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">git push origin -u master</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p><strong>Step 6.</strong>&nbsp;In the end, just remove the <em>folder-b</em> from the original repository using <em>git rm -rf</em></p>
<!-- /wp:paragraph -->

<!-- wp:preformatted {"className":"lang:scala decode:true"} -->
<pre class="wp-block-preformatted lang:scala decode:true">git rm -rf folder-b</pre>
<!-- /wp:preformatted -->

<!-- wp:paragraph -->
<p>Please comment below, If you face any issues or if you have any questions on above!</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><span style="text-decoration: underline;"><strong>References -</strong></span></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="https://stackoverflow.com/questions/359424/detach-move-subdirectory-into-separate-git-repository" target="_blank" rel="noreferrer noopener nofollow">https://stackoverflow.com/questions/359424/detach-move-subdirectory-into-separate-git-repository</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="https://help.github.com/en/articles/splitting-a-subfolder-out-into-a-new-repository" target="_blank" rel="noreferrer noopener nofollow">https://help.github.com/en/articles/splitting-a-subfolder-out-into-a-new-repository</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>More Interesting articles on saurzcode -</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="https://saurzcode.in/2015/01/hive-sort-order-distribute-cluster/" target="_blank" rel="noreferrer noopener">Hive : SORT BY vs ORDER BY vs DISTRIBUTE BY vs CLUSTER BY</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="https://saurzcode.in/2019/09/running-spark-application-on-windows/" target="_blank" rel="noreferrer noopener">Spark - How to Run Spark Applications on Windows</a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="https://saurzcode.in/2017/10/configure-spark-application-eclipse/" target="_blank" rel="noreferrer noopener">How to Configure Spark Application ( Scala and Java 8 Version with Maven ) in Eclipse.</a></p>
<!-- /wp:paragraph -->