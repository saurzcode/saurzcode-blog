---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
title: "SaurzCode Developer Blog"
description: "Big Data, Spark, and Developer Tutorials"
---

# 🚀 SaurzCode Developer Blog

Welcome! Here you'll find hands-on tutorials, guides, and deep dives into Big Data, Spark, Java, and more.

---

<div class="medium-feed">
  {%- for post in site.posts -%}
    <div class="medium-card">
      <a href="{{ post.url | relative_url }}" class="medium-title">{{ post.title }}</a>
      <div class="medium-meta">
        <span class="medium-date">{{ post.date | date: "%b %-d, %Y" }}</span>
        {%- if post.tags -%}
          <span class="medium-tags"> | Tags: {{ post.tags | join: ", " }}</span>
        {%- endif -%}
      </div>
      {%- if post.description -%}
        <p class="medium-desc">{{ post.description }}</p>
      {%- elsif post.excerpt -%}
        <p class="medium-desc">{{ post.excerpt | strip_html | truncate: 160 }}</p>
      {%- endif -%}
    </div>
  {%- endfor -%}
</div>

<style>
.medium-feed {
  display: flex;
  flex-direction: column;
  gap: 2em;
  margin: 2em 0;
}
.medium-card {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
  padding: 2em 1.5em;
  transition: box-shadow 0.2s;
  border: 1px solid #eee;
}
.medium-card:hover {
  box-shadow: 0 4px 16px rgba(0,0,0,0.10);
  border-color: #007acc33;
}
.medium-title {
  font-size: 1.5em;
  font-weight: 700;
  color: #222;
  text-decoration: none;
  margin-bottom: 0.2em;
  display: block;
}
.medium-title:hover {
  color: #007acc;
  text-decoration: underline;
}
.medium-meta {
  color: #888;
  font-size: 0.95em;
  margin-bottom: 0.7em;
}
.medium-tags {
  color: #007acc;
}
.medium-desc {
  color: #333;
  font-size: 1.08em;
  margin: 0.5em 0 0 0;
}
@media (max-width: 600px) {
  .medium-card { padding: 1em 0.7em; }
  .medium-title { font-size: 1.15em; }
}
</style>
