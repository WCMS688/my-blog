# WCMS688 的博客

这是一个使用 Hugo 搭建、部署到 Cloudflare Pages 的极简中文博客。

站点地址：

- <https://my-blog-avn.pages.dev>

## 本地预览

```powershell
hugo server
```

打开 <http://localhost:1313/>

## 一键提交并推送

仓库根目录已经提供脚本：

```powershell
.\publish.ps1
```

如果你想直接双击或用更短命令，也可以：

```powershell
.\publish.bat
```

这个脚本也可以在资源管理器里直接双击运行。

也可以带提交说明：

```powershell
.\publish.ps1 -Message "新增文章：xxx"
```

或：

```powershell
.\publish.bat -Message "新增文章：xxx"
```

## 新增文章

方式一：用 Hugo 生成新文件

```powershell
hugo new posts/my-new-post.md
```

方式二：把你现有的 Markdown 文章直接放到：

```text
content/posts/
```

如果文章里带图片，统一按下面的目录规则处理：

```text
static/uploads/文章-slug/图片名.png
```

Markdown 中这样引用：

```md
![配图说明](/uploads/文章-slug/图片名.png)
```

这类图片会和文章一起进入 Git 仓库，并随 `git push` 同步到 GitHub，Cloudflare Pages 部署时也会一并发布。

文章头部建议使用这类 Front Matter：

```toml
+++
title = "文章标题"
date = 2026-04-07T20:00:00+08:00
draft = false
slug = "article-slug"
description = "文章摘要"
tags = ["Hugo", "建站"]
categories = ["教程"]
columns = ["Hugo 专栏"]
+++
```

## 开专栏

本项目已经启用自定义 taxonomy：

- `columns`

你以后只要在文章里写：

```toml
columns = ["Hugo 专栏"]
```

Hugo 就会自动生成：

- `/columns/`
- `/columns/hugo-专栏/`

适合用来做：

- Hugo 建站
- AI 工具
- 编程随笔
- 学习笔记

## 发布流程

每次更新文章后执行：

```powershell
.\publish.ps1 -Message "更新博客内容"
```

Cloudflare Pages 会自动重新构建部署。
