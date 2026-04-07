# Project Memory

本文件记录本工程开发与调试过程中已经确认的关键事实、历史问题和经验，供后续 agent 快速建立上下文。

## 已确认事实

- 这是一个 Hugo 静态博客工程，不依赖外部主题
- 站点部署到 Cloudflare Pages
- 线上地址：<https://my-blog-avn.pages.dev>
- GitHub 仓库：<https://github.com/WCMS688/my-blog>
- 当前 Hugo 版本：`0.160.0 extended`

## 部署相关记忆

- Cloudflare Pages 当前可用配置：
  - Framework preset：`Hugo`
  - Build command：`hugo --gc --minify -b $CF_PAGES_URL`
  - Output directory：`public`
  - Environment variable：`HUGO_VERSION=0.160.0`

- `config.toml` 中的 `baseURL` 已改为真实线上地址，不再是占位值

## 内容相关记忆

- 示例文章 `content/posts/first-post.md` 已经删除
- 当前正式文章示例为：
  - `content/posts/hfss-learning-guide.md`
- taxonomy 已启用：
  - `tags`
  - `categories`
  - `columns`

## 图片方案记忆

- 目前明确采用方案 A：图片跟随仓库一起管理
- 图片统一放在 `static/uploads/文章-slug/`
- 文章中通过 `/uploads/...` 路径引用
- 之所以没有切到外部图床，是因为虽然用户提到中科大数据胶囊 S3，但尚未验证是否具备稳定的公开直链能力

## 发布脚本记忆

- 日常入口是 `publish.bat`
- 复杂逻辑在 `publish.ps1`
- 发布脚本后来做过一次重要修复：
  - PowerShell 在只有单个改动项时，可能把输出当成标量，导致 `.Count` 报错
  - 现在脚本已通过 `@( ... )` 包装关键输出，避免单项结果触发属性缺失

- 发布脚本当前支持：
  - `-DryRun`
  - `-AllowFutureDate`
  - `-NoPush`
  - `-Message`

- 发布脚本默认策略：
  - 检查未来时间文章
  - 一篇文章及其图片优先单独 commit
  - 非文章改动单独形成站点级 commit

## 已踩过的坑

### 1. 未来时间文章不会显示

现象：

- 文章文件存在
- 本地/线上页面却看不到文章

原因：

- Hugo 默认不会发布 `date` 或 `publishDate` 晚于当前时间的非草稿文章

本项目中真实发生过一次：

- `hfss-learning-guide.md` 最初写成了未来时间，导致首页和文章列表看不到它

处理结论：

- 以后发文要避免未来时间，或明确使用 `-AllowFutureDate`

### 2. 桌面端正文“放大后仍显得偏空”

现象：

- 页面整体变宽了
- 但正文阅读列没有与标题区域边界统一，右侧看起来像“空了一块”

原因：

- 早期样式只扩大了外层容器和文章页宽度
- 正文段落仍受较窄的内部限制，造成头部和正文不在同一阅读列

处理结论：

- 后续调桌面端阅读宽度时，要同时看外层容器、标题区和正文区三者对齐

### 3. 文章目录出现“重复编号”

现象：

- 标题本身写了 `1.`、`1.1`
- Hugo 的 TOC 如果配置成有序列表，会额外生成一层编号

处理结论：

- `markup.tableOfContents.ordered` 已改为 `false`
- 目录样式也去掉了默认列表符号
- 目录现在只显示标题原本的编号文本

### 4. Hugo 本机缓存目录权限问题

现象：

- 运行 `hugo --gc --minify` 时，出现类似：
  - `failed to prune cache "getresource"`
  - `Access is denied`

原因：

- 当前环境对默认缓存目录 `C:\Users\Administrator\AppData\Local\hugo_cache\...` 可能存在权限限制

处理结论：

- 在当前机器上，优先使用绝对路径缓存目录：

```powershell
hugo --gc --minify --cacheDir D:\AAA_MyWorkplaces\MyBlog\.hugo_cache_local
```

### 5. Git push 可能被凭证流程卡住

现象：

- `git push` 没有明显报错，但没有成功推上去
- 或者只显示到 Git Credential Manager / remote-https 阶段

原因：

- 本机 GitHub 认证有时会进入浏览器或凭证管理器交互

处理结论：

- 如果 agent 侧推送无响应，不一定是 Git 命令错了，可能只是需要用户在本机完成认证

## 模板与布局记忆

- 文章页右侧目录来自 `.TableOfContents`
- 目录高亮通过 `IntersectionObserver` 实现
- 移动端目录退化为单列显示，不固定在右侧
- 最近一次布局优化重点是让标题区与正文区共享统一阅读列

## 后续 agent 建议

- 接手前先读：
  - `AGENTS.md`
  - `Memory.md`
  - `README.md`

- 改动模板或脚本后优先验证：
  - `.\publish.bat -DryRun`
  - `hugo --gc --minify --cacheDir D:\AAA_MyWorkplaces\MyBlog\.hugo_cache_local`
