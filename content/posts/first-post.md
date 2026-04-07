+++
title = "第一篇文章"
date = 2026-04-07T10:00:00+08:00
draft = false
slug = "first-post"
description = "这是 Hugo 博客的第一篇示例文章。"
tags = ["Hugo", "Cloudflare Pages", "博客"]
categories = ["建站"]
+++

欢迎来到我的第一篇博客文章。

这是一套极简 Hugo 博客示例，重点是：

- 结构简单，容易理解和修改
- 适配中文内容
- 支持代码高亮
- 可以直接部署到 Cloudflare Pages

## 为什么选择 Hugo

Hugo 的优点是生成速度快、目录结构清晰、对 Markdown 支持很好，很适合搭建个人博客或文档网站。

## 示例代码

下面是一段示例代码，确认代码高亮是否正常：

```bash
hugo server
```

如果你要发布到 Cloudflare Pages，构建命令建议使用：

```bash
hugo -b $CF_PAGES_URL
```

## 接下来可以做什么

你可以继续：

1. 修改 `config.toml` 中的网站标题和描述。
2. 新增更多文章到 `content/posts/`。
3. 把仓库推送到 GitHub，然后连接 Cloudflare Pages 自动部署。
