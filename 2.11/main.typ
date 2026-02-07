// ============================================================
// main.typ - Typst 学术写作模版
// ============================================================

#import "lib.typ": *

// --- 全局页面设置 ---
#set text(font: ("New Computer Modern", "Source Han Serif SC", "SimSun"), size: 11pt, lang: "zh")
#set par(justify: true, leading: 0.8em, first-line-indent: 2em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#set figure(placement: auto)

// --- 封面页 ---
#page(numbering: none, margin: (top: 3cm, bottom: 3cm, left: 2.5cm, right: 2.5cm))[

  #align(center)[
    #v(2cm)

    #text(size: 16pt, tracking: 6pt, weight: "bold")[某某大学]

    #v(0.8cm)

    #thick-line

    #v(0.8cm)

    #text(size: 28pt, weight: "bold")[论文标题]

    #text(size: 14pt, fill: luma(80))[Paper Title in English]

    #v(0.8cm)

    #thick-line

    #v(2cm)
  ]

  #align(center)[
    #set text(size: 12pt)
    #grid(
      columns: (80pt, 200pt),
      row-gutter: 16pt,
      align: (right, left),

      [*学　　院：*], [计算机科学与技术学院],
      [*专　　业：*], [计算机科学与技术],
      [*学生姓名：*], [张　三],
      [*学　　号：*], [20240001],
      [*指导教师：*], [李四 教授],
    )
  ]

  #v(1fr)

  #align(center)[
    #text(size: 12pt)[#datetime.today().display("[year]年[month]月[day]日")]
  ]
]

// --- 目录页 ---
#page(numbering: none)[
  #outline(
    title: [目 录],
    depth: 3,
    indent: auto,
  )
]

// --- 正文开始，设置页码 ---
#set page(numbering: "1", number-align: center)
#counter(page).update(1)

// ============================================================
//  第一章 引言
// ============================================================
= 引言 <intro>

本模版演示了 Typst 学术写作的基本结构，包括封面、目录、图片、表格以及参考文献引用。

Typst 是一种现代排版系统，具有简洁的语法和快速的编译速度，适合学术论文写作 @wikipedia_iosevka。相较于传统的 LaTeX，Typst 提供了更为直观的标记语言，同时保持了高质量的排版输出 @knuth1984texbook。

#thin-line

== 研究背景

随着学术写作需求的不断增长，研究者需要一套高效、易用的排版工具。传统工具虽然功能强大，但学习曲线陡峭 @lamport1994latex。本文展示了 Typst 模版的基本用法。

== 研究目标

本研究的主要目标如下：

+ 构建一个简洁实用的 Typst 学术模版
+ 演示图片、表格、公式的使用方法
+ 展示参考文献的引用方式

// ============================================================
//  第二章 方法
// ============================================================
= 方法

== 公式示例

行内公式 $E = m c^2$ 可以直接嵌入文本中。独立公式如下：

$ L(theta) = sum_(i=1)^(N) log p(x_i | theta) $ <eq:likelihood>

我们可以通过 @eq:likelihood 来引用该公式。

== 算法描述

#info-box[
  本节介绍了实验中使用的主要算法流程。具体实现细节详见源代码。
]

算法的核心步骤为：

+ 数据预处理与特征提取
+ 模型参数初始化
+ 迭代优化目标函数
+ 评估并输出结果

// ============================================================
//  第三章 实验
// ============================================================
= 实验

== 实验设置

实验在以下环境中进行，硬件与软件配置见 @tab:env。

#figure(
  table(
    columns: (1fr, 2fr),
    align: (center, left),
    stroke: 0.5pt,

    table.header(
      [*配置项*], [*详细信息*],
    ),

    [操作系统],  [Ubuntu 22.04 LTS],
    [处理器],    [Intel i9-13900K],
    [内存],      [64 GB DDR5],
    [GPU],       [NVIDIA RTX 4090 (24 GB)],
    [语言],      [Python 3.11],
    [框架],      [PyTorch 2.1],
  ),
  caption: [实验环境配置],
) <tab:env>

== 实验结果

各方法在测试集上的表现如 @tab:results 所示。

#figure(
  table(
    columns: (auto, 1fr, 1fr, 1fr),
    align: (left, center, center, center),
    stroke: 0.5pt,

    table.header(
      [*方法*], [*准确率 (%)*], [*精确率 (%)*], [*F1 值 (%)*],
    ),

    [Baseline],       [82.3], [80.1], [81.2],
    [Method A],       [87.6], [85.4], [86.5],
    [Method B],       [89.1], [88.2], [88.6],
    [*Ours*],         [*92.4*], [*91.7*], [*92.0*],
  ),
  caption: [各方法在测试集上的实验结果对比],
) <tab:results>

从 @tab:results 可以看出，我们的方法在所有指标上均优于基线方法。

#dashed-line

== 图片示例

@fig:example 展示了一个示例图片。请将实际图片文件放置在 `figures/` 目录下。

#figure(
  rect(width: 60%, height: 120pt, fill: luma(230), stroke: 0.5pt + luma(180))[
    #align(center + horizon)[
      #text(fill: luma(120), size: 10pt)[placeholder: 替换为实际图片 \ `image("figures/example.png")`]
    ]
  ],
  caption: [示例图片（请替换为实际图片）],
) <fig:example>

#tip-box[
  使用实际图片时，将上方的 `rect(...)` 替换为：\
  `image("figures/your-image.png", width: 80%)`
]

// ============================================================
//  第四章 讨论
// ============================================================
= 讨论

== 结果分析

实验结果表明，我们提出的方法在多个评测指标上取得了显著提升。具体而言：

- *准确率*提高了约 10 个百分点
- *F1 值*从 81.2% 提升至 92.0%

== 局限性

#warning-box[
  当前方法在以下场景中存在局限：大规模数据集的处理效率有待优化；模型在领域迁移时性能可能下降。
]

// ============================================================
//  第五章 结论
// ============================================================
= 结论

本文介绍了一个基于 Typst 的学术写作模版，演示了封面、目录、图表、公式及参考文献引用等常见功能。该模版可作为学术论文写作的起点，研究者可根据实际需求进行扩展和定制。

// ============================================================
//  参考文献
// ============================================================
#pagebreak()

#bibliography("refs.bib", title: "参考文献", style: "ieee")
