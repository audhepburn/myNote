# 个人时间线笔记应用设计文档

**日期**: 2026-01-13
**技术栈**: SwiftUI + SwiftData + iOS 17+
**存储**: 纯本地

## 概述

一个类似 X/Twitter 的个人笔记应用，用于快速记录灵感、学习笔记和待办事项。支持短笔记、多标签、多图片，按时间线浏览。

---

## 1. 整体架构

### 应用架构
- **架构模式**: MVVM
- **UI 框架**: SwiftUI
- **数据持久化**: SwiftData (iOS 17+)
- **图片存储**: Documents 目录 + SwiftData 路径引用

### 核心数据模型

```swift
@Model
class Note {
    var id: UUID
    var content: String              // 笔记内容 (200-500字)
    var createdAt: Date
    var isPinned: Bool               // 置顶
    var isFavorite: Bool             // 收藏
    var images: [NoteImage]          // 一对多
    var tags: [Tag]                  // 多对多
}

@Model
class Tag {
    var id: UUID
    var name: String
    var color: String                // 十六进制颜色
    var useCount: Int                // 使用次数
}

@Model
class NoteImage {
    var id: UUID
    var note: Note?                  // 反向关系
    var imagePath: String            // Documents/images/ 下的文件路径
    var orderIndex: Int              // 显示顺序
}
```

### SwiftData 配置
```swift
.modelContainer(for: [Note.self, Tag.self, NoteImage.self])
```
- 启用自动保存
- 图片独立存储，SwiftData 仅保存路径

---

## 2. 核心组件

### TimelineView (主时间线)
- **布局**: LazyVStack 实现高效滚动
- **数据源**: `@Query` 动态监听 SwiftData 变化
- **分区**:
  - 置顶笔记区 (`isPinned == true`)
  - 普通笔记区 (按 createdAt 倒序)
- **交互**:
  - 下拉刷新 (`.refreshable`)
  - 无限滚动 (批次加载 20 条)
  - 滑动删除

### NoteCell (笔记单元格)
```
┌─────────────────────────────┐
│ 2小时前                      │  ← 相对时间
│                              │
│ 这是笔记内容...              │  ← 文本 (截断/展开)
│                              │
│ [图] [图] [图] +5            │  ← 缩略图 (最多3张)
│                              │
│ #灵感 #学习                  │  ← 标签胶囊 (横向滚动)
│                              │
│ [★] [📌] [🗑]               │  ← 操作栏
└─────────────────────────────┘
```

### ComposeView (新建笔记)
- **文本输入**: TextEditor + 字数统计 (实时显示剩余字数)
- **图片选择**: PhotosPicker 多选，最多 9 张
- **标签输入**: 支持 `#标签名` 语法，或手动选择已有标签
- **发布验证**: 字数为 0 时禁用发布按钮

---

## 3. 数据流与业务逻辑

### 笔记创建流程
```
用户输入 → 验证 → 创建 Note → 压缩图片 → 保存文件 → SwiftData 持久化 → Timeline 刷新
```

### 图片处理
1. **压缩**: 限制 1080px，质量 0.8
2. **文件名**: `{UUID}.jpg`
3. **存储路径**: `Documents/images/{filename}`
4. **缩略图缓存**: `Library/Caches/Thumbnails/`

### 标签管理
- **创建**: 输入时检查重复，不存在则新建
- **计数**: 创建/删除笔记时更新 `Tag.useCount`
- **删除**: 仅 `useCount == 0` 的标签可删除

### 置顶与收藏
- **置顶**: `isPinned = true`，时间线优先显示
- **收藏**: `isFavorite = true`，用于筛选和统计
- 直接修改 SwiftData 对象属性，自动持久化

---

## 4. 统计与导出

### StatsView (统计面板)
- **总笔记数**: `@Query` count
- **本周笔记数**: 过滤最近 7 天
- **最常用标签**: 按 `useCount` 排序，显示 Top 5-10
- **活跃度趋势**: 过去 30 天的柱状图
- **图片统计**: 总数、平均/笔记

### 数据导出
- **JSON**: 完整数据结构，包含 Note/Tag/NoteImage
- **Markdown**: 按时间线格式化
  ```markdown
  ## 2026-01-13

  #灵感 #学习 今天学习了 SwiftUI...
  ![图片](path/to/image.jpg)
  ```
- **分享方式**: `ShareLink` 或导出到 Files

---

## 5. 导航与主题

### 导航结构
```
TabView
├── Timeline → TimelineView → NoteDetailView
├── Tags → TagsView → (筛选后) TimelineView
├── Stats → StatsView
└── Settings → SettingsView
```

### ComposeView 模态弹出
- 使用 `.sheet()` 或 `.fullScreenCover()`

### 深色模式
- 跟随系统: `.preferredColorScheme(nil)`
- 自适应颜色: `.foregroundStyle(.primary)`
- 图片深色模式: 适当降低不透明度

---

## 6. 性能优化

- **LazyVStack**: 仅渲染可见区域
- **图片缩略图**: 后台生成并缓存
- **分页加载**: `fetchLimit = 20`
- **即时压缩**: 选择图片时即处理

---

## 7. 错误处理

| 场景 | 处理方式 |
|------|---------|
| 图片保存失败 | Alert 提示存储空间/权限 |
| SwiftData 保存失败 | 捕获异常，记录日志 |
| 导出失败 | Toast 提示重试 |
| 存储空间不足 | 警告，阻止新操作 |

---

## 8. 测试策略

- **单元测试**: 数据模型、图片压缩、标签匹配
- **UI 测试**: 创建流程、删除、筛选
- **SwiftData 测试**: 使用 in-memory container 隔离

---

## 功能优先级

### P0 (核心功能)
- [x] 短笔记创建 (200-500字)
- [x] 时间线浏览
- [x] 多标签支持
- [x] 多图片上传 (最多9张)
- [x] 置顶/收藏
- [x] 删除笔记

### P1 (重要功能)
- [x] 统计面板
- [x] 数据导出 (JSON/Markdown)
- [x] 标签筛选
- [x] 深色模式

### P2 (增强功能)
- [ ] 全文搜索 (暂不实现)
- [ ] 笔记编辑 (不支持，保持原味)
- [ ] 云同步 (未来考虑)
