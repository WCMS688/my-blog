# AGENTS

本文件面向后续继续维护此工程的 agent，记录本项目的工作规范与约定。

## 项目概况

- 项目类型：Hugo 静态博客
- 部署平台：Cloudflare Pages
- 线上地址：<https://my-blog-avn.pages.dev>
- 主要语言：中文
- 当前主题策略：自定义轻量模板，不依赖外部 Hugo 主题仓库

## 目录与内容约定

- 文章放在 `content/posts/`
- 关于页在 `content/about/index.md`
- 首页内容在 `content/_index.md`
- 文章列表页在 `content/posts/_index.md`
- 自定义分类专栏使用 taxonomy：`columns`
- 专栏入口路径：`/columns/`

## 发文规范

- 文章 Front Matter 使用 TOML
- 文章必须显式写 `draft = false` 才会发布
- 文章应提供 `title`、`date`、`slug`、`description`
- 如需归档到专栏，使用 `columns = ["专栏名"]`
- 文章正文字段建议从 `##` 开始写一级正文标题，以便右侧目录结构更稳定

推荐 Front Matter 结构：

```toml
+++
title = "文章标题"
date = 2026-04-07T20:00:00+08:00
draft = false
slug = "article-slug"
description = "文章摘要"
tags = ["标签1", "标签2"]
categories = ["分类"]
columns = ["专栏名"]
+++
```

## 图片规范

- 本项目当前采用“本地图片随仓库管理”的方案
- 图片统一存放在 `static/uploads/文章-slug/`
- Markdown 中使用绝对站内路径引用，例如：

```md
![配图说明](/uploads/article-slug/fig-01.png)
```

- 不要在 Markdown 中写本机绝对路径，如 `C:\...`
- 不要把图片随意堆在 `static/uploads/` 根目录

## 模板与样式规范

- 模板位于 `layouts/`
- 样式集中在 `static/css/style.css`
- 当前没有引入复杂 JS 框架，文章目录高亮仅使用内联原生脚本
- 桌面端文章页采用“正文主列 + 右侧目录”布局
- 目录不应再叠加额外自动编号，只保留文章标题自身已有的编号文本
- 调整桌面端宽度时，优先保证“标题区、正文区、目录区”的边界对齐，不要单纯放大容器

## 发布与 Git 规范

- 日常发布入口统一使用 `publish.bat`
- `publish.bat` 内部调用 `publish.ps1`
- 非必要不要直接绕过发布脚本手动 `git add . && git commit && git push`

发布脚本当前具备这些行为：

- 自动检查文章是否是未来时间；若不是 `draft` 且发布时间晚于当前时间，会阻止提交
- 自动按文章拆分提交；一篇文章及其对应图片尽量形成单独 commit
- 非文章类改动会合并成站点级 commit

常用命令：

```powershell
.\publish.bat -DryRun
.\publish.bat
.\publish.bat -Message "Update site layout"
.\publish.bat -AllowFutureDate
```

## 部署约定

- GitHub 仓库：`https://github.com/WCMS688/my-blog`
- 默认分支：`main`
- Cloudflare Pages 构建命令：`hugo --gc --minify -b $CF_PAGES_URL`
- 输出目录：`public`
- 环境变量：`HUGO_VERSION=0.160.0`

## 修改时的工作习惯

- 修改模板或样式后，优先本地运行：

```powershell
hugo --gc --minify --cacheDir D:\AAA_MyWorkplaces\MyBlog\.hugo_cache_local
```

- 若只改发布脚本，至少执行一次：

```powershell
.\publish.bat -DryRun
```

- 做文章页相关改动时，要同时检查：
  - 首页文章列表是否正常
  - `/posts/` 列表页是否正常
  - 单文章页目录是否正常
  - 移动端是否退化为单列布局
- 在排查问题、修复 bug、确认框架限制或总结部署/发布经验后，若形成了对后续维护有价值的结论，应默认同步更新 `Memory.md`
- 更新 `Memory.md` 时，优先记录：
  - 已确认根因的问题
  - 本项目特有的渲染/配置/部署限制
  - 已验证可复用的处理结论或命令
  - 后续 agent 容易重复踩坑的注意事项

## 不要做的事

- 不要重新引入外部主题或子模块，除非用户明确要求
- 不要把文章图片改成依赖本机路径
- 不要随意修改已有文章 slug，除非用户明确要求；这会影响线上链接
- 不要把未来时间文章直接发布，除非用户明确要求定时发布
- 不要用会导致正文宽度失衡的样式改动破坏文章阅读体验

## 配套记忆文档

工程运行与调试中积累的坑和关键背景，见 `Memory.md`。
- 后续 agent 不应只在对话中解释结论；凡是确认有长期价值的经验，原则上都应补写进 `Memory.md`
