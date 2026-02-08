// ============================================================
// main.typ - Typst 学术写作模版
// ============================================================

#import "../Template Typst/lib.typ": *

// --- 全局页面设置 ---
#set text(font: ("New Computer Modern", "Source Han Serif SC", "SimSun"), size: 11pt, lang: "zh")
#set par(justify: true, leading: 0.8em, first-line-indent: 2em)
#set heading(numbering: "1.1")
#set math.equation(numbering: "(1)")
#show figure.where(kind: table): set figure.caption(position: top)

// --- 封面页 ---
#page(numbering: none, margin: (top: 3cm, bottom: 3cm, left: 2.5cm, right: 2.5cm))[

  #align(center)[
    #v(2cm)


    #v(0.8cm)

    #thick-line

    #v(0.8cm)

    #text(size: 28pt, weight: "bold")[关于文本鉴伪的两篇论文]

    #text(size: 14pt, fill: luma(80))[2026.2.11分享]

    #v(0.8cm)

    #text(size: 14pt, fill: luma(80))[LiuKai]
    #thick-line

    #v(2cm)
  ]

  #align(center)[
    #set text(size: 12pt)
    #grid(
      columns: (80pt, 200pt),
      row-gutter: 16pt,
      align: (right, left),
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



= Ghostbuster 论文

== Introduction

本文全称 "Ghostbuster: Detecting Text Ghostwritten by Large Language Models" ,发表在 ICLR 2024 上。文章主要提出了一种的方法来检测文本，把文本经过 概率计算-特征选择-分类器计算 的流程进行判别。简单来说，作者提出了一种方法，先通过暴力枚举从所有特征中最值得计算的特征，然后拿这些特征进行计算，掌握这些特征之后，就使用一个简单的线性分类器进行鉴别。

#figure(
  image("figures/overview.pdf", width: 80%),
  caption: "Ghostbuster 框架示意图",
)

== Methodology

=== Probability Computation

关于概率计算部分，作者首先定义了一系列操作（see @Table1）， Vector FUnctions 之间可以自由组合，对向量进行操作，然后 Scalar Functions 是最后一步，把操作出来的向量变成标量。
#figure(
 three-line-table(
    columns: (1fr, 1fr),
    header:([*Vector Functions*], [*Scalar Functions*]),
    [$f_"add" = p_1 + p_2$], [$f_"max" = max p$],
    [$f_"sub" = p_1 - p_2$], [$f_"min" = min p$],
    [$f_"mul" = p_1 dot.op p_2$], [$f_"avg" = 1/|p| sum_i p_i$],
    [$f_"div" = p_1 / p_2$], [$f_"avg-top25" = 1/|p| sum_(i in T_p) p_i$],
    [$f_(>) = bb(1)_{p_1 > p_2}$], [$f_"len" = |p|$],
    [$f_(<) = bb(1)_{p_1 < p_2}$], [$f_"L2" = ||p||_2$],
    [], [$f_"var" = 1/n sum_i (p_i - mu_p)^2$],
  ),
  caption: "Ghostbuster定义向量操作列表"
)<Table1>

=== Feature Selection

定义了以上操作，作者先用Unigram, Trigram, GPT-3 Ada, Davinci 模型的Token序列作为输入向量，然后经过 Vector Functions 和 Scalar Functions 的任意组合，暴力枚举出所有可能的特征组合，最后得到一个特征集合 S。得到 S 之后，作者根据 @Algorithm1 进行枚举，每一轮只选一个让当前模型性能提升最大的特征，一直枚举直到加任何新特征都不能提升性能。除了电脑枚举，作者还加入了人工选择的特征进行矫正，最终你会得出最终特征集合 S。

#let indent = h(1.5em)

#figure(
  // 使用三线表函数，设置为单列左对齐
  three-line-table(
    columns: (1fr),
    align: left,
    
    // 表头：对应图片中的 "Algorithm 1 ..."
    header: ([*Algorithm 1* Subroutine FIND-ALL-FEATURES],),

    // 表格主体：放入一个内容块中
    [
      // 1. Require 部分
      *Require:* The previously picked feature $p$, depth $d < "max_depth"$, vectors $V$ of token probabilities (from unigram, trigram, ada, and davinci models), scalar functions $F_s$, vector functions $F_v$ \
      
      // 2. Ensure 部分
      *Ensure:* A list of all possible features \
      
      // 3. 算法逻辑主体
      Let $S = emptyset$ \
      *for all* scalar functions $f_s in F_s$ *do* \
        #indent Add $f_s(p)$ to $S$ \
      *end for* \
      
      *for all* combinations of features and vector functions $(p', f_v) in V times F_v$ *do* \

        #indent Add Find-All-Features($f_v(p, p'), d + 1$) to $S$ \
      *end for*
    ]
  )
)<Algorithm1>

=== Classifier Training

拿到特征集合 S 之后，作者使用一个简单的线性分类器（Logistic Regression）进行训练，最终得到一个鉴别文本是否由 LLM 生成的模型。关于这里为什么作者只使用 最简单的线性分类器，我们在后续的 Ablation Study 中进行分析。

== Results

在 Metric 上，作者使用了 F1 Score 来评测模型性能，结果如 @Figure2 所示，Ghostbuster 在所有数据集上都显著优于之前的 SOTA 方法。同时还表现出了很好的泛化能力，例如在新闻上训练，在作文上测试仍然可行，说明 Ghostbuster 是学到了文本生成的通用特征进行鉴别。

#figure(
  image("figures/Results.png", width: 90%),
  caption: "Ghostbuster 在不同数据集上的表现",
)<Figure2>

== Analysis

=== Ablation Study

关于这里，作者主要分析了三方面： max_depth 和 feature selection 的重要性和分类器的选择。关于 max_depth，作者发现当 max_depth = 3 时性能最好，说明过于复杂的特征组合反而会导致过拟合。关于 feature selection，作者发现不使用人类提供的特征会导致模型泛化能力下降，说明人工选择的特征在模型训练中起到了重要的矫正作用。而分类器的选择上，使用复杂的分类方式（例如神经网络）反而导致性能下降，这是因为输入的特征本身经过了复杂模型处理的高级非线性信号了，再使用神经网络会导致过拟合。



#pagebreak()

#bibliography("refs.bib", title: "参考文献", style: "ieee")
