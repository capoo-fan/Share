#import "../Template Typst/lib.typ": *

// --- 全局页面设置 ---
#set text(font: ("Source Han Serif SC", "SimSun"), size: 11pt, lang: "zh")
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

    #text(size: 14pt, fill: luma(80))[#datetime.today().display("[year]年[month]月[day]日")分享]

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


= Abstract 
本文介绍了两篇关于文本鉴伪的论文，两篇都是发布于 ICLR 2024 的文章。分别是 Ghostbuster @ghostbuster2024 和 Raidar @raidar2024 。前者是通过枚举特征，然后鉴别，后者类似 DNA-GPT 的方法，后者的方法可以提供更好的解释性质。

= Ghostbuster 论文

== Introduction

本文全称 "Ghostbuster: Detecting Text Ghostwritten by Large Language Models" @ghostbuster2024 ,发表在 ICLR 2024 上。文章主要提出了一种的方法来检测文本，把文本经过 概率计算-特征选择-分类器计算 的流程进行判别。简单来说，作者提出了一种方法，先通过暴力枚举从所有特征中最值得计算的特征，然后拿这些特征进行计算，掌握这些特征之后，就使用一个简单的线性分类器进行鉴别。

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
    header: ([*Vector Functions*], [*Scalar Functions*]),
    [$f_"add" = p_1 + p_2$],
    [$f_"max" = max p$],
    [$f_"sub" = p_1 - p_2$],
    [$f_"min" = min p$],
    [$f_"mul" = p_1 dot.op p_2$],
    [$f_"avg" = 1/|p| sum_i p_i$],
    [$f_"div" = p_1 / p_2$],
    [$f_"avg-top25" = 1/|p| sum_(i in T_p) p_i$],
    [$f_(>) = bb(1)_(p_1 > p_2)$],
    [$f_"len" = |p|$],
    [$f_(<) = bb(1)_(p_1 < p_2)$],
    [$f_"L2" = ||p||_2$],
    [],
    [$f_"var" = 1/n sum_i (p_i - mu_p)^2$],
  ),
  caption: "Ghostbuster定义向量操作列表",
)<Table1>

=== Feature Selection

定义了以上操作，作者先用Unigram, Trigram, GPT-3 Ada, Davinci 模型的Token序列作为输入向量，然后经过 Vector Functions 和 Scalar Functions 的任意组合，暴力枚举出所有可能的特征组合，最后得到一个特征集合 S。得到 S 之后，作者根据 @Algorithm1 进行枚举，每一轮只选一个让当前模型性能提升最大的特征，一直枚举直到加任何新特征都不能提升性能。除了电脑枚举，作者还加入了人工选择的特征进行矫正，最终你会得出最终特征集合 S。

#let indent = h(1.5em)

#figure(
  // 使用三线表函数，设置为单列左对齐
  three-line-table(
    columns: 1fr,
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
    ],
  ),
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


= Raidar 论文介绍

== Introduction

Raidar @raidar2024 论文的方法有点类似于 DNA-GPT @dnagpt2024 ,DNA-GPT 是给 LLM 一段文本，然后补写，然后比对补写部分与原先部分的区别。而 Raidar 论文就是把目标文本输入给 LLM ，然后让 LLM 进行 Polish (润色)，然后比对润色前后文本的区别，来判断文本是否是 LLM 生成的。
其中的底层原理是，LLM 对自己写的文本都很自信，然后认为人类写的文本不够好，所以会进行大幅度的润色，而对于 LLM 生成的文本，LLM 认为已经很好了，所以润色的幅度就比较小。

#figure(
  image("figures/teaser.pdf", width: 80%),
  caption: "Raidar 原理展示图",
)

== Methodology

设 $F(dot)$ 是 LLM ,给定输入文本是 x,以后输出分类标签 y，方法观察结果是给定相同重写提示词，LLM写的文本会被视为高质量输入，修改很少而人类文本会被进行更多的编辑。其中的提示词类似：

```` txt
1. Help me polish this:
2. Rewrite this for me:
3. Refine this for me please:
````
同时论文假设当呗多次重写的时候，LLM 生成的文本将比人类撰写的文本更稳定。作者还定义了输出的方差作为一种检测的度量。
$
  U=sum_(i=1)^(K-1)sum_(j=i)^(K)D(x_(i)^(prime),x_(j)^(prime))
$


然后就需要计算两段文本之间的差异了，Raidar 使用了两种方法:

=== 词袋编辑 (Bag-of-words edit)

计算逻辑如下：
1. 提取： 将“原始文本”和“重写后的文本”都拆解成一个个的 n-词块（比如 3 个词一组）。
2. 找共同点： 统计有多少个词块是同时出现在两个文本里的。
3. 算比例： 用共同词块的数量除以输入文本的长度。

=== Levenshtein 分数 (Levenshtein Score)

Levenshtein 分数就是用于衡量将一个字符串改写为另一个字符串所需的最小单字符编辑次数。论文中使用标准动态规划算法计算 Levenshtein 分数，分数越高表示两个字符串越相似。设重写输出 $s_k=F(p_k,x)$。 然后计算比率:
$
  D_(k)(x,s_(k))=1-("Levenshtein"(s_(k),x))/max("len"(s_(k)), "len"(x)))
$


== Results

下面是 Raidar 论文的结果展示，Raidar 在所有数据集上都显著优于之前的 SOTA 方法，同时在不同的重写提示词上表现也很稳定，说明 Raidar 的方法是比较鲁棒的。

// Table 1
// Table 2

#figure(
  caption: [
    Raidar 的结果展示
  ],
  image("figures/Table1&2.png", width: 80%),
)


对于用一个模型进行训练，检测其他模型生成的文本，Raidar 也表现出了很好的泛化能力。下面的表格是使用 GPT 3.5 进行训练。

// Table 4
#figure(
  caption: [
    Raidar GPT 3.5 训练效果
  ],
  image("figures/Table4.png", width: 80%),
)


对于不同模型进行重写，如果不用类似 GPT-3.5 的大模型，使用小模型，效果依旧显著。
// Table 5
#figure(
  caption: [
    Raidar 小模型重写效果
  ],
  image("figures/Table5.png", width: 80%),
)

#v(3em)

// Table 5



同时， Raidar 也表现出了关于文本长度越长，鉴别效果也好的趋势。

#figure(
  caption: [
    Raidar 文本长度与鉴别效果的关系
  ],
  image("figures/len_ablation-eps-converted-to.pdf", width: 80%),
)

== Advantages

- 这种方法优点之一是相比 Detect-GPT @detectgpt2023 不需要 LLM 内部的 Token 概率，只需要文本输入输出即可，适用范围更广。
- 同时  Levenshtein 分数是离散的，也就是不可微。攻击者无法简单的通过梯度下降来优化输入文本来欺骗模型。
- Raidar 是给予离散符号进行运作的，一个词没有概率分布，不存在中间状态，要么是 A 要么是 B,这样使算法对输入微小的噪声脱敏，只要整体结构和用词没有变化，检测结果不会发生大的改变。

#pagebreak()

#bibliography("refs.bib", title: "参考文献", style: "ieee")
