// ============================================================
// lib.typ - 学术写作模版预定义工具库
// ============================================================

// --- 分割线 ---

/// 细分割线
#let thin-line = line(length: 100%, stroke: 0.5pt + black)

/// 粗分割线
#let thick-line = line(length: 100%, stroke: 1.5pt + black)

/// 双分割线
#let double-line = {
  line(length: 100%, stroke: 0.8pt + black)
  v(2pt)
  line(length: 100%, stroke: 0.8pt + black)
}

/// 虚线分割线
#let dashed-line = line(length: 100%, stroke: (dash: "dashed", thickness: 0.8pt))

/// 点线分割线
#let dotted-line = line(length: 100%, stroke: (dash: "dotted", thickness: 1pt))

// --- 文本样式 ---

/// 关键词高亮
#let keyword(body) = text(weight: "bold", fill: rgb("#1a5276"), body)

/// 强调文本（带底色）
#let highlight-text(body) = box(
  fill: rgb("#fef9e7"),
  inset: (x: 4pt, y: 2pt),
  radius: 2pt,
  body,
)

/// 行内代码
#let code(body) = box(
  fill: luma(240),
  inset: (x: 4pt, y: 2pt),
  radius: 2pt,
  text(font: ("Fira Code", "Source Code Pro", "Courier New"), size: 0.9em, body),
)

// --- 注释框 ---

/// 通用注释框
#let note-box(title: "Note", color: rgb("#3498db"), body) = block(
  width: 100%,
  inset: 12pt,
  radius: 4pt,
  stroke: (left: 3pt + color),
  fill: color.lighten(92%),
  [
    #text(weight: "bold", fill: color, title) \
    #body
  ],
)

/// 警告框
#let warning-box(body) = note-box(title: "Warning", color: rgb("#e74c3c"), body)

/// 提示框
#let tip-box(body) = note-box(title: "Tip", color: rgb("#27ae60"), body)

/// 信息框
#let info-box(body) = note-box(title: "Info", color: rgb("#3498db"), body)

// --- 图表辅助 ---

/// 带编号的图片（居中）
#let fig(path, caption: "", width: 80%) = figure(
  image(path, width: width),
  caption: caption,
)

/// 带编号的子图排列（水平）
#let subfigures(items, caption: "") = figure(
  grid(
    columns: items.len(),
    column-gutter: 12pt,
    ..items.map(item => image(item.path, width: 100%)),
  ),
  caption: caption,
)

/// 带编号的表格
#let tab(content, caption: "") = figure(
  content,
  kind: table,
  caption: caption,
)

#let three-line-table(
  columns: auto,
  align: center,
  header: (),
  ..data
) = {
  table(
    columns: columns,
    align: align,
    stroke: none, // 禁用默认网格线

    // 1. 顶线 (粗)
    table.hline(y: 0, stroke: 1.5pt),

    // 2. 表头区域 (包含下方的细分界线)
    table.header(
      ..header,
      table.hline(stroke: 0.75pt) // 表头下的分界线 (细)
    ),

    // 3. 数据主体
    ..data,

    // 4. 底线 (粗)
    table.hline(stroke: 1.5pt),
  )
}

// --- 封面辅助 ---

/// 封面信息条目
#let cover-entry(label-text, value) = {
  grid(
    columns: (auto, 1fr),
    column-gutter: 12pt,
    text(weight: "bold", label-text + "："),
    value,
  )
}
