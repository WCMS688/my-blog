+++
title = "CoWoS 为什么这么关键：台积电先进封装的横纵分析"
date = 2026-05-02T20:00:00+08:00
draft = false
slug = "tsmc-cowos-advanced-packaging-hv-analysis"
description = "台积电 CoWoS 先进封装分析，覆盖 CoWoS-S/R/L、HBM、硅中介层、SoIC/InFO 与 Intel、Samsung 等竞品比较。"
tags = ["TSMC", "CoWoS", "Advanced Packaging", "Chiplet", "HBM", "2.5D", "3DFabric", "先进封装"]
categories = ["硬件设计"]
columns = ["高速电路专栏"]

+++

# TSMC CoWoS 先进封装横纵分析报告

> 研究时间：2026-05-03  
> 研究对象：TSMC CoWoS（Chip-on-Wafer-on-Substrate，晶圆上芯片再上基板封装）、3DFabric（台积电 3D 硅堆叠与先进封装技术族）、AI/HPC（人工智能/高性能计算）先进封装生态  
> 方法：横纵分析法

## 一句话判断

CoWoS 的本质不是一种「更高级的封装外壳」，而是一种把逻辑芯片、chiplet（芯粒）、HBM（High Bandwidth Memory，高带宽存储器）和封装互连重新组织成系统的技术平台。它让 AI GPU、HPC 加速器、网络 ASIC（专用集成电路）绕开单片 reticle limit（光罩尺寸上限）和外部内存带宽瓶颈，直接在一个 package（封装）里构建高带宽、低延迟、高功耗密度的计算系统。

如果只用一句工程话概括：

CoWoS 把先进封装从后道工艺，推成了 AI 计算架构的核心基础设施。

它的竞争力不只来自硅中介层或 RDL（Redistribution Layer，重新布线层），而来自一整套能力：先进逻辑制程、HBM 生态、interposer（中介层）制造、TSV（Through-Silicon Via，硅通孔）、substrate（封装基板）、thermal（散热）、SI/PI（信号完整性/电源完整性）、EDA（电子设计自动化）参考流程、良率和量产爬坡。也正因为如此，CoWoS 既是台积电的技术护城河，也是 AI 供应链里最显眼的瓶颈之一。

## 纵向分析：CoWoS 为什么变成今天这个位置

### 第一阶段：单片芯片撞上面积、良率和带宽墙

传统 SoC（System-on-Chip，片上系统）的发展路径很清楚：把更多功能集成到一片大 die（裸片）里。CPU、GPU、cache、IO、memory controller、SerDes（高速串并转换器），能放进去就放进去。

但先进制程走到 7nm、5nm、3nm、2nm 后，问题开始集中爆发。

第一，单片 die 不能无限变大。光刻 reticle size 大约在 800 多平方毫米量级，超过这个范围就无法一次曝光出完整芯片。即使不碰到物理上限，大 die 的 yield（良率）也会随着面积增加而恶化。

第二，不是所有功能都适合最先进节点。逻辑计算适合先进制程，IO、模拟、电源、SerDes、部分 SRAM（静态随机存储器）不一定适合。把所有模块都强行放在同一个先进节点上，会浪费成本。

第三，AI/HPC 的性能瓶颈越来越多来自内存带宽。GPU 或 AI accelerator（AI 加速器）再强，如果不能以足够带宽访问 HBM，算力就会被饿住。

Chiplet 的思路就是把系统拆开：逻辑 die、IO die、HBM stack（HBM 堆叠）、cache die、特殊加速器分别制造，再用先进封装拼回系统。CoWoS 正好解决了这个「拼回去」的问题。

### 第二阶段：CoWoS-S 用硅中介层打开 2.5D 路线

CoWoS 最经典的形态是 CoWoS-S。TSMC 官方把 CoWoS-S 描述为 Chip on Wafer on Substrate with Silicon Interposer（基于硅中介层的晶圆上芯片再上基板封装）。它的基本结构是：逻辑 die 和 HBM 放在 silicon interposer（硅中介层）上，再通过 interposer 下方的 TSV 和封装基板连接到外部。

硅中介层的价值在于高密度布线。相比传统 organic substrate（有机基板），硅中介层可以提供更细的线宽线距、更高的互连密度和更好的信号控制。这让逻辑芯片和多个 HBM stack 可以在封装内以极高带宽连接。

2020 年，TSMC 与 Broadcom 宣布 CoWoS 平台支持 2X reticle size interposer（约 1700 mm²）。官方新闻稿称，该平台可容纳多个逻辑 SoC die，并支持最多 6 个 HBM cubes，容量最高 96GB，带宽最高 2.7 TB/s，是 2016 年 CoWoS 方案的 2.7 倍。

2021 年 ECTC 论文进一步披露了第五代 CoWoS-S：3-reticle size，约 2500 mm² silicon interposer，可容纳总面积 1200 mm² 的多个逻辑芯片和 8 个 HBM stack。论文还提到 integrated deep trench capacitor（iCap，集成深沟槽电容）用于增强电源完整性，5 层 sub-micron Cu interconnect（亚微米铜互连）降低片间连接电阻，新的 TSV 结构改善插入损耗和回波损耗，高导热 TIM（Thermal Interface Material，热界面材料）降低热阻。

这说明 CoWoS 的演进不是单纯变大，而是同时补 SI、PI、thermal 和 reliability（可靠性）。

### 第三阶段：AI 大模型让 CoWoS 从先进封装变成产能瓶颈

2023 年之后，AI 训练和推理需求暴涨，CoWoS 的位置彻底变了。过去先进封装是「高端芯片可选项」，现在对 NVIDIA、AMD、Google、Amazon、Broadcom 等 AI/HPC 客户来说，它是高端加速器能否出货的关键路径。

TSMC 2024 年报明确说，CoWoS advanced packaging service（CoWoS 先进封装服务）自 2023 年以来因 AI 需求激增而强劲增长。年报还提到，CoWoS-S 的硅中介层尺寸在过去十年从 1.0 reticle 扩展到 3.3 reticle；发展重心转向 CoWoS-L，首个 3.5-reticle CoWoS-L 已在 2024 年进入生产，并启动 5.5-reticle interposer 目标的新开发。

TSMC 2025 年报继续把 CoWoS、InFO、TSMC-SoIC 和 COUPE（Compact Universal Photonic Engine，紧凑通用光子引擎）列为支撑大规模低功耗互连的关键技术。这里有一个信号：台积电已经不再把先进封装当作「后道服务」，而是和 N2、A16、A14 这类先进工艺一起放进长期技术领导力叙事里。

这也是为什么市场反复讨论 CoWoS 产能。AI GPU 缺货不只缺晶圆，也缺 HBM、substrate、CoWoS 封装线、测试、散热和系统组装。CoWoS 是其中最集中、最容易被看见的瓶颈。

### 第四阶段：CoWoS-S/R/L 分化，走向更大封装和更多设计弹性

现在的 CoWoS 已经不是单一技术，而是一个家族。TSMC 官方页面列出三条路线：

- CoWoS-S：silicon interposer，主打最高性能和最高密互连；
- CoWoS-R：RDL interposer，主打更柔性的聚合物/铜 RDL 中介层；
- CoWoS-L：RDL-based interposer + embedded local silicon interconnect（LSI，嵌入式局部硅互连），试图在大尺寸、可扩展性和局部高密互连之间折中。

CoWoS-S 当前官方页面提到可支持 up to 3.3X-reticle size（约 2700 mm²）interposer，更大尺寸则推荐 CoWoS-L 或 CoWoS-R。CoWoS-R 的 RDL interposer 最小 pitch 可到 4 μm，使用 2 μm line width/spacing，并通过 coplanar GSGSG（地-信号-地-信号-地）和 interlayer ground shielding（层间地屏蔽）改善电气性能。CoWoS-L 则引入 LSI chip（局部硅互连芯片），支持高密 die-to-die interconnect，并可集成 stand-alone eDTC（独立嵌入式深沟槽电容）改善电源管理。

公开报道显示，TSMC 2026 年技术研讨会继续把 CoWoS 往更大尺寸推进，路线图讨论到超过 14-reticle 的 SiP（System-in-Package，系统级封装）和 24 个 HBM5E stack 的未来形态。这个信息来自媒体对 2026 North America Technology Symposium 的报道，属于公开报道而非我直接看到的 TSMC 官方技术白皮书；但趋势与 TSMC 2024 年报中从 3.3 到 3.5/5.5 reticle 的演进方向一致。

## 横向分析：CoWoS 家族内部怎么分工

### 1. CoWoS-S：性能最强，但硅中介层成本和尺寸压力最大

CoWoS-S 是最经典、也是 AI/HPC 最具代表性的路线。它的核心是大尺寸 silicon interposer。

优势：

- 互连密度高；
- 适合 HBM 与逻辑 die 的超高带宽连接；
- SI/PI 控制好；
- 可集成 deep trench capacitor（深沟槽电容）增强 PDN（Power Distribution Network，电源分配网络）；
- 适合顶级 AI GPU、HPC accelerator、networking ASIC。

挑战：

- 硅中介层面积越大，制造和良率压力越高；
- reticle stitching（光刻拼接）复杂；
- TSV、热、翘曲、C4 bump（可控塌陷芯片连接凸点）可靠性都更难；
- 成本高；
- 产能爬坡慢。

一句话：CoWoS-S 是性能优先路线，适合最顶级的 AI/HPC 产品。

### 2. CoWoS-R：用 RDL interposer 降低部分机械和成本压力

CoWoS-R 使用 RDL interposer。TSMC 官方说明中提到，RDL interposer 由 polymer（聚合物）和 copper traces（铜走线）组成，相对柔性更好，有助于改善 C4 joint integrity（C4 焊点完整性），并能缓冲 SoC 与 substrate 的 CTE（Coefficient of Thermal Expansion，热膨胀系数）不匹配。

优势：

- 柔性更好，机械可靠性可能更友好；
- RDL 线可支持高速信号和电源完整性优化；
- 可能更适合某些大尺寸或成本敏感的异构集成。

挑战：

- 互连密度通常不如纯硅中介层；
- 高频损耗和电源完整性需要精细设计；
- 对顶级 HBM 带宽场景，是否能替代 CoWoS-S 要看具体设计。

一句话：CoWoS-R 更像大尺寸异构集成中的弹性路线。

### 3. CoWoS-L：在大尺寸和局部高密互连之间折中

CoWoS-L 是现在最值得关注的路线。它结合 RDL-based interposer 和 embedded local silicon interconnect（LSI）。简单理解，CoWoS-L 不把整个大中介层都做成昂贵硅中介层，而是在关键局部位置嵌入高密 LSI，其他区域用更大尺寸、更可扩展的 RDL/模塑结构承载。

TSMC 官方说明中提到，LSI 可以提供多层 sub-micron copper lines（亚微米铜线）的高密 die-to-die interconnect，可用于 SoC-to-SoC、SoC-to-chiplet、SoC-to-HBM 等连接；CoWoS-L 还能在 SoC 下方集成 stand-alone eDTC，改善 power management（电源管理）。

优势：

- 支持更大封装尺寸；
- 局部需要高密互连的地方用 LSI，成本/面积更可控；
- 有利于未来 12 HBM、更多 chiplet、更大 AI accelerator；
- 比纯硅大中介层更具扩展潜力。

挑战：

- 结构更复杂；
- LSI 与 RDL/模塑结构之间的协同设计更难；
- SI/PI/thermal/mechanical co-design（信号、电源、热、机械协同设计）要求更高；
- EDA flow 和封装设计规则更复杂。

一句话：CoWoS-L 是 TSMC 为后 AI 大封装时代准备的主力扩展路线。

## CoWoS 和 TSMC 其他 3DFabric 技术的关系

TSMC 3DFabric 不是只有 CoWoS。官方把 3DFabric 描述为包括 TSMC-SoIC、CoWoS、InFO 的 3D silicon stacking 和 advanced packaging 技术族。

### CoWoS vs SoIC

SoIC（System on Integrated Chips，系统整合芯片）是 frontend 3D stacking（前道三维堆叠）路线。它强调 ultra-high-density vertical stacking（超高密垂直堆叠），通过极短 die-to-die 连接降低 RLC（电阻/电感/电容），提升带宽、功耗和形态。

CoWoS 是 backend 2.5D advanced packaging（后道 2.5D 先进封装）路线，擅长把逻辑 die 和 HBM side-by-side（并排）放在中介层上。

两者不是替代关系。TSMC 官方 SoIC 页面明确提到，SoIC integrated chips 可以再通过 CoWoS 或 InFO 组装，用于下一代 HPC、AI 和移动应用。

也就是说，未来高端系统可能是：

```text
多个 die 先用 SoIC 垂直堆成 3D chiplet
再把这些 3D chiplet 和 HBM 放进 CoWoS
最后形成更大的 SiP
```

### CoWoS vs InFO

InFO（Integrated Fan-Out，集成扇出封装）更强调 fan-out wafer-level packaging（扇出型晶圆级封装），适合移动、网络、某些高密高性能但成本/厚度更敏感的应用。InFO-oS 可以支持 logic-to-logic integration，用高密 fine-pitch RDL 支持 chiplet 间高速通信。

CoWoS 更适合最高性能 AI/HPC，尤其是 HBM 密集连接。

简单说：

- 需要 HBM、极高带宽、最大封装：优先 CoWoS；
- 需要更薄、更成本敏感、更偏移动/网络：考虑 InFO；
- 需要垂直堆叠、最短互连：看 SoIC；
- 需要更极端的 wafer-scale：看 TSMC-SoW。

## CoWoS 的工程核心

### 1. HBM 是 CoWoS 的第一性需求

今天讨论 CoWoS，绕不开 HBM。AI GPU 需要巨大的内存带宽，而 HBM 必须通过非常宽、非常短的互连接到逻辑芯片。传统 PCB 上的 GDDR 或 DIMM 路线无法满足这种带宽密度和功耗效率。

CoWoS 把 GPU/ASIC 和 HBM 放在同一 interposer 上，直接提供高密 die-to-die 布线。2020 年 TSMC/Broadcom 新闻稿提到 2X reticle CoWoS 可支持 6 HBM cubes、96GB 容量和 2.7 TB/s 带宽；后续 CoWoS-S5 论文提到 8 HBM stack；2024 年报和后续路线则把重心推向更大 interposer 和更多 HBM。

所以 CoWoS 的核心指标不是「封装面积」本身，而是：

- 能放多少 HBM stack；
- 每个 HBM 的接口速率和总带宽；
- logic-to-HBM 的 SI/PI margin（裕量）；
- HBM 与逻辑 die 的热耦合；
- 封装良率和测试策略。

### 2. 尺寸扩展是 CoWoS 的主线，但不是唯一主线

CoWoS 一直在变大。从 1X reticle 到 2X、3X、3.3X、3.5X、5.5X，公开路线甚至讨论更大 SiP。尺寸变大带来的好处很直接：更多逻辑 die、更多 HBM、更多 I/O（输入输出）、更大系统级算力。

但尺寸变大也带来四个问题：

- lithography stitching 难；
- warpage（翘曲）和机械应力难；
- thermal path 难；
- yield 和测试成本难。

所以 CoWoS-L 的出现很有逻辑：不能无限依赖一整块巨大 silicon interposer，而要在局部高密互连和大尺寸封装之间做结构性折中。

### 3. PI 和热不是附属问题，而是 CoWoS 成败条件

AI 芯片的封装功耗已经极高，HBM stack 也有热源属性。CoWoS 中逻辑 die 和 HBM 靠得很近，热耦合、TIM、lid（盖板）、冷板、液冷、封装翘曲都会影响性能。

同样，CoWoS 里的 PDN 也不能只靠 package substrate。大电流瞬态、HBM 同步访问、logic die 多 tile 负载变化，都会在 interposer 和 substrate 上制造电源噪声。CoWoS-S5 论文提到 iCap/eDTC 这类深沟槽电容，就是为了把电容放到更接近负载的地方，压低中高频 PDN 阻抗。

这说明先进封装设计已经进入 system technology co-optimization（系统技术协同优化）阶段。

### 4. EDA 和设计规则是 CoWoS 落地的隐形门槛

CoWoS 不是有版图就能做。多 die 系统需要：

- package planning（封装规划）；
- die placement（裸片摆放）；
- bump map（凸点映射）；
- interposer routing（中介层布线）；
- SI/PI/thermal co-simulation（协同仿真）；
- mechanical stress analysis（机械应力分析）；
- DRC/LVS（设计规则检查/版图一致性检查）；
- test planning（测试规划）；
- assembly yield model（组装良率模型）。

Cadence 2022 年宣布 Integrity 3D-IC 平台通过 TSMC 3DFabric 认证，并支持 TSMC 3Dblox 标准；2020 年 Cadence 也宣布 IC packaging reference flow 通过 TSMC InFO 和 CoWoS-S 参考流程认证。这类 EDA 新闻看起来像生态宣传，但对工程很关键：没有成熟流程，CoWoS 这样的多 die 封装很难规模化交付。

## 横向比较：CoWoS 和其他先进封装方案

### 1. TSMC CoWoS vs Intel EMIB / Foveros

Intel 的先进封装组合是 EMIB（Embedded Multi-die Interconnect Bridge，嵌入式多裸片互连桥）和 Foveros（Intel 3D 堆叠封装）。Intel 官方说明中，EMIB 是 2.5D side-by-side（并排）集成，用 embedded silicon bridge（嵌入式硅桥）连接多个 die；Foveros 是 3D stacking（3D 堆叠），Foveros Direct 使用 Cu-to-Cu hybrid bonding（铜到铜混合键合）。

和 CoWoS 相比：

- CoWoS-S 用大 silicon interposer，适合大规模 HBM + 逻辑集成；
- EMIB 用局部 silicon bridge，不需要整块大中介层，理论上成本和基板集成更灵活；
- Foveros 更强调垂直堆叠；
- Intel 2026 年前后在先进封装上更强调外部代工和美国本土封装供应链；
- CoWoS 的优势是成熟客户量产、NVIDIA/AMD/AI 生态和 TSMC 先进制程绑定；
- Intel 的潜在优势是 EMIB/Foveros 组合、美国/马来西亚/葡萄牙等地理弹性，以及与 UCIe（通用芯粒互连标准）生态结合。

简化判断：

```text
最大 AI/HBM 量产生态：CoWoS 领先
局部桥接和灵活封装路线：EMIB 有差异化
3D 垂直集成：Foveros / SoIC 更直接对位
```

### 2. TSMC CoWoS vs Samsung I-Cube / H-Cube / X-Cube

Samsung 的 2.5D 路线包括 I-Cube 和 H-Cube。Samsung 官方 I-Cube4 新闻稿称，I-Cube4 把一个 logic die 和 4 个 HBM 放在 silicon interposer 上，用于 HPC、AI/cloud、data center。H-Cube 则面向 6 个以上 HBM 的高性能 2.5D 封装，并使用 hybrid-substrate structure（混合基板结构）解决大面积封装需求。

Samsung 的 X-Cube 是 3D IC packaging，使用 TSV 支持 SRAM-logic 等 3D 堆叠。

和 CoWoS 相比：

- I-Cube/H-Cube 在技术方向上与 CoWoS 类似，都是 logic + HBM + interposer；
- Samsung 的潜在优势是 memory + foundry + packaging 垂直整合，特别是 HBM 供应链协同；
- CoWoS 的现实优势是 AI GPU 客户量产经验、先进逻辑制程份额、生态成熟度和产能爬坡；
- Samsung 若能在 HBM4、foundry 和 packaging 上形成闭环，会对 CoWoS 构成长期竞争。

### 3. CoWoS vs OSAT 先进封装

ASE、Amkor、SPIL、Powertech 等 OSAT（Outsourced Semiconductor Assembly and Test，外包封装测试厂）在封装测试产业里很强，但 CoWoS 这种和先进制程、HBM、EDA flow、硅中介层制造高度耦合的业务，对 foundry（晶圆代工厂）更有利。

不过，随着需求爆发，OSAT 不会被排除在外。TSMC 自己的先进封装产能有限，未来部分 substrate assembly、测试、后段模组、区域化供应链可能会和 OSAT 合作。Amkor 与先进封装、美国本土封装的关系也会越来越重要。

CoWoS 的竞争不只是技术，还包括谁能提供完整可信的 supply chain（供应链）。

## 适用场景

### 优先考虑 CoWoS 的场景

- AI GPU / AI accelerator，需要 4、6、8、12 颗甚至更多 HBM；
- HPC processor，需要超高内存带宽和多 chiplet 互连；
- networking ASIC，需要大 die 拆分和高带宽片间连接；
- custom AI ASIC，需要先进节点逻辑 + HBM + 大封装；
- 超大 reticle 受限设计，需要通过 2.5D 方式绕过单片面积上限；
- 需要 TSMC 先进制程与封装协同优化的项目。

### 不适合优先考虑 CoWoS 的场景

- 成本极度敏感、带宽需求不高；
- 移动端薄型封装，InFO 可能更合适；
- die 数少、I/O 带宽不高，传统 flip-chip BGA 足够；
- 只需要垂直堆叠而不需要大面积 HBM 横向集成，SoIC/Foveros/X-Cube 可能更直接；
- 项目量不够大，难以承受 CoWoS NRE（Non-Recurring Engineering，一次性工程成本）和供应链复杂度。

## 工程检查清单

### A. 架构阶段

| 检查项 | 判定标准 |
|---|---|
| 是否必须用 CoWoS | HBM 带宽、chiplet 数量、封装面积和功耗密度是否超过传统封装能力 |
| CoWoS-S/R/L 选择 | 硅中介层性能、RDL 成本/柔性、LSI 局部高密互连需求是否明确 |
| HBM 配置 | HBM 代际、stack 数、容量、带宽、供应商和热设计同时评估 |
| Die partition | 逻辑、IO、cache、SerDes、HBM 控制器拆分是否有成本/良率收益 |
| Reticle strategy | 单片 die 面积、interposer 面积、stitching 风险和未来扩展路径明确 |
| TSMC 生态依赖 | 制程、封装、IP、EDA flow、substrate、HBM 供应链风险纳入 |

### B. 封装与物理设计

| 检查项 | 判定标准 |
|---|---|
| Interposer routing | logic-to-HBM、logic-to-logic 通道带宽、线宽线距、屏蔽策略明确 |
| SI 验证 | insertion loss、return loss、crosstalk、skew、eye margin 覆盖 |
| PI 验证 | PDN impedance、eDTC/iCap、C4/TSV/substrate 电源路径覆盖 |
| Thermal 设计 | logic die、HBM、TIM、lid、冷板、液冷接口、热梯度评估 |
| Warpage / stress | 大尺寸 package 翘曲、C4 bump、underfill、substrate 应力检查 |
| Test access | die-level、interposer-level、package-level 测试点和 BIST 规划 |

### C. 量产与供应链

| 检查项 | 判定标准 |
|---|---|
| KGD 策略 | Known Good Die（已知良品裸片）测试、binning（分档）、traceability（追溯）明确 |
| HBM 供应 | HBM 供应商、良率、热特性、代际迁移计划明确 |
| Substrate 供应 | 大尺寸高层数 substrate 产能和良率风险评估 |
| CoWoS 产能 | 封装 slot、排产周期、客户优先级和备选路线明确 |
| Yield 模型 | die yield、interposer yield、assembly yield、test yield 全链路估算 |
| Failure analysis | 失效定位、返修可能性、封装解剖和量产监控流程明确 |

## 风险与难点

### 1. CoWoS 不是万能扩展器

CoWoS 可以突破单片 die 面积和外部内存带宽瓶颈，但它会把问题转移到封装复杂度、热、供电、良率、测试和供应链。系统变大以后，失败点也变多。

### 2. 大尺寸封装的热和机械问题越来越硬

AI 加速器的封装功耗和 HBM 数量持续上升，CoWoS 的热路径和机械可靠性会成为设计边界。未来封装不是只靠导热材料和散热器，而要从 die placement、power map、HBM 排布、冷板和系统风道一起设计。

### 3. CoWoS 产能会继续影响 AI 芯片节奏

TSMC 年报确认 CoWoS 因 AI 需求强劲增长并持续扩产。公开报道也多次提到 CoWoS capacity（CoWoS 产能）紧张。即使先进逻辑晶圆足够，如果 CoWoS、HBM、substrate、测试或系统组装任何一环不够，最终 AI 服务器仍然出不来。

### 4. 竞争正在从「封装技术」变成「封装生态」

Intel、Samsung、OSAT、EDA 厂、HBM 厂都在围绕先进封装重新站位。CoWoS 当前领先，但未来竞争会变成：

- 谁能提供更多 HBM；
- 谁能做更大 package；
- 谁能把热和电源做稳；
- 谁能提供更完整的 EDA flow；
- 谁能在不同地区提供可信产能；
- 谁能把 chiplet 标准化到可复用。

## 横纵交汇洞察

### 洞察一：CoWoS 是 AI 时代的「新主板」

过去，主板负责连接 CPU、GPU、内存和 IO。今天，在 AI 加速器里，CoWoS 正在把一部分主板功能前移到封装内部。GPU die、HBM、IO chiplet、甚至未来的 optical IO（光 IO）都可能先在 package 内完成系统级连接。

这就是为什么 CoWoS 重要。它不是封装变高级了，而是系统边界变了。

### 洞察二：CoWoS 的瓶颈来自它太成功

CoWoS 成功解决了 AI 芯片的 HBM 带宽问题，也因此被所有高端 AI 客户同时需要。需求高度集中，技术门槛高，产能建设慢，导致它成为供应链瓶颈。

这不是 CoWoS 的失败，而是它变成关键基础设施后的自然结果。

### 洞察三：CoWoS-L 代表下一阶段方向

CoWoS-S 证明了 silicon interposer + HBM 的价值，但下一阶段的难题是更大、更复杂、更可量产。CoWoS-L 用 LSI 做局部高密互连，用 RDL/模塑结构承载更大尺寸，是一种很现实的工程折中。

如果说 CoWoS-S 是「把高密互连做到极致」，CoWoS-L 更像「把高密互连放在最需要的地方」。

## 结论

CoWoS 是台积电 3DFabric 里最具产业影响力的先进封装路线之一。它的技术核心是 2.5D heterogeneous integration（异构集成）：通过 silicon interposer、RDL、LSI、TSV、eDTC/iCap、HBM 和大尺寸 substrate，把多个先进逻辑 die 与高带宽存储器整合成一个封装内系统。

它的商业核心则更直接：AI/HPC 需要的不是单个更快的晶体管，而是更大的系统级算力、更高的内存带宽和更好的能效。CoWoS 正好站在这个交汇点上。

我的判断是：

短期内，CoWoS 仍然会是顶级 AI 加速器最重要的先进封装平台，产能和 HBM 供应会继续影响 NVIDIA、AMD、云厂商自研 ASIC 的出货节奏。中期看，CoWoS-L、SoIC + CoWoS、CPO（Co-Packaged Optics，共封装光学）会把封装从「连接逻辑和 HBM」推进到「构建封装内系统」。长期看，CoWoS 的竞争不再只是 interposer 技术，而是台积电能否把制程、封装、EDA、HBM、光互连、热设计和供应链组织成一个稳定可扩展的平台。

## 信息来源

- TSMC, 3DFabric: https://3dfabric.tsmc.com/english/dedicatedFoundry/technology/3DFabric.htm
- TSMC, CoWoS official page: https://3dfabric.tsmc.com/english/dedicatedFoundry/technology/cowos.htm
- TSMC, 3DFabric for High-Performance Computing: https://www.tsmc.com/english/dedicatedFoundry/technology/platform_HPC_tech_WLSI.htm
- TSMC, Advanced Packaging Solutions: https://www.tsmc.com/chinese/dedicatedFoundry/services/advanced-packaging
- TSMC, 2024 Annual Report: https://investor.tsmc.com/static/annualReports/2024/english/index.html
- TSMC, 2025 Annual Report: https://investor.tsmc.com/static/annualReports/2025/english/index.html
- TSMC and Broadcom, World’s First 2X Reticle Size Interposer: https://pr.tsmc.com/schinese/news/2026
- Huang et al., Wafer Level System Integration of the Fifth Generation CoWoS-S with High Performance Si Interposer at 2500 mm2, ECTC 2021: https://colab.ws/articles/10.1109%2FECTC32696.2021.00028
- TSMC Research, Off-chip Interconnect Publications: https://research.tsmc.com/chinese/research/interconnect/off-chip-interconnect/publish-time-1.html
- Cadence, Integrity 3D-IC Platform Certified for TSMC 3DFabric: https://www.cadence.com/en_US/home/company/newsroom/press-releases/pr/2022/cadence-integrity-3d-ic-platform-certified-for-tsmc-3dfabric.html
- Cadence, IC Packaging Reference Flow Certified for TSMC InFO and CoWoS: https://www.cadence.com/en_US/home/company/newsroom/press-releases/pr/2020/cadence-ic-packaging-reference-flow-certified-for-the-latest-tsm.html
- Intel, Advanced Packaging Innovations: https://www.intel.com/content/www/us/en/foundry/packaging.html
- Samsung, I-Cube4 advanced 2.5D integration: https://news.samsung.com/global/samsung-electronics-announces-availability-of-its-next-generation-2-5d-integration-solution-i-cube4-for-high-performance-applications/1000
- Samsung, H-Cube 2.5D packaging solution: https://news.samsung.com/global/samsung-announces-availability-of-its-leading-edge-2-5d-integration-h-cube-solution-for-high-performance-applications/1000
- Samsung, X-Cube 3D IC technology: https://news.samsung.com/global/samsung-announces-availability-of-its-silicon-proven-3d-ic-technology-for-high-performance-applications
- Tom’s Hardware, TSMC 2026 CoWoS roadmap reporting: https://www.tomshardware.com/tech-industry/semiconductors/tsmcs-details-next-gen-cowos-roadmap-over-14-reticle-packages-and-48x-leap-in-compute-power-expected-by-2029-massive-size-enables-24-hbm5e-stacks-and-additional-memory-bandwidth-jump

## 中英术语对照表

| 中文术语 | 英文术语 / 缩写 | 说明 |
|---|---|---|
| 晶圆上芯片再上基板封装 | Chip-on-Wafer-on-Substrate, CoWoS | 台积电 2.5D 先进封装平台 |
| 三维硅堆叠与先进封装技术族 | 3DFabric | 台积电先进封装和 3D 堆叠技术组合 |
| 芯粒 | Chiplet | 被拆分出来并通过封装互连组合的功能芯片单元 |
| 裸片 | Die | 晶圆切割后的单个芯片 |
| 系统级封装 | System-in-Package, SiP | 多个 die/chiplet/无源器件集成在一个封装内的系统形式 |
| 片上系统 | System-on-Chip, SoC | 多个功能模块集成在单片硅上的系统 |
| 高性能计算 | High Performance Computing, HPC | 高算力服务器、超级计算、AI 训练等场景 |
| 高带宽存储器 | High Bandwidth Memory, HBM | 通过 TSV 堆叠并行接口实现超高带宽的存储器 |
| 硅中介层 | Silicon Interposer | 位于逻辑 die 和基板之间的硅基高密互连层 |
| 重新布线层 | Redistribution Layer, RDL | 封装中用于重新分配 I/O 和连接 die 的金属布线层 |
| 硅通孔 | Through-Silicon Via, TSV | 穿过硅衬底的垂直互连结构 |
| 局部硅互连 | Local Silicon Interconnect, LSI | CoWoS-L 中嵌入的局部高密硅互连芯片 |
| 深沟槽电容 | Deep Trench Capacitor, DTC / eDTC / iCap | 集成在中介层或封装附近用于改善电源完整性的电容结构 |
| 电源分配网络 | Power Distribution Network, PDN | 从电源到负载的完整供电网络 |
| 信号完整性 | Signal Integrity, SI | 关注高速信号损耗、反射、串扰、眼图和抖动 |
| 电源完整性 | Power Integrity, PI | 关注电源噪声、阻抗、压降和瞬态响应 |
| 热界面材料 | Thermal Interface Material, TIM | 芯片和散热结构之间用于降低热阻的材料 |
| 光罩尺寸上限 | Reticle Limit | 单次光刻曝光可覆盖的最大版图尺寸 |
| 光刻拼接 | Lithography Stitching | 用多次曝光拼接实现超 reticle 大面积结构 |
| 有机基板 | Organic Substrate | 常见封装基板材料体系 |
| 可控塌陷芯片连接 | Controlled Collapse Chip Connection, C4 | 芯片到封装互连的焊凸点技术 |
| 底部填充 | Underfill | 芯片和基板/中介层之间用于机械支撑和可靠性的填充材料 |
| 翘曲 | Warpage | 封装因热膨胀、材料和应力不匹配产生的形变 |
| 热膨胀系数 | Coefficient of Thermal Expansion, CTE | 材料随温度变化的膨胀程度 |
| 设计规则检查 | Design Rule Check, DRC | 检查版图是否符合制造规则 |
| 版图一致性检查 | Layout Versus Schematic, LVS | 检查版图连接是否与原理/网表一致 |
| 已知良品裸片 | Known Good Die, KGD | 经测试确认可用于封装组装的裸片 |
| 一次性工程成本 | Non-Recurring Engineering, NRE | 项目前期设计、掩膜、验证、封装开发等一次性投入 |
| 外包封装测试厂 | Outsourced Semiconductor Assembly and Test, OSAT | 提供封装和测试服务的第三方厂商 |
| 晶圆代工厂 | Foundry | 提供晶圆制造服务的半导体厂商 |
| 嵌入式多裸片互连桥 | Embedded Multi-die Interconnect Bridge, EMIB | Intel 局部硅桥 2.5D 封装技术 |
| 3D 堆叠封装 | Foveros | Intel 的 3D 先进封装技术 |
| Interposer-Cube | I-Cube | Samsung 的 2.5D interposer 封装路线 |
| Hybrid-Substrate Cube | H-Cube | Samsung 的大面积 2.5D 混合基板封装方案 |
| eXtended-Cube | X-Cube | Samsung 的 3D IC 封装技术 |
| 共封装光学 | Co-Packaged Optics, CPO | 把光互连模块与计算/交换芯片封装到更近位置的技术 |
| 紧凑通用光子引擎 | Compact Universal Photonic Engine, COUPE | 台积电发展中的硅光/光 IO 相关平台 |
| 系统技术协同优化 | System Technology Co-Optimization, STCO | 从系统、封装、芯片和工艺共同优化性能/功耗/成本 |
| 电子设计自动化 | Electronic Design Automation, EDA | 芯片和封装设计仿真验证软件体系 |
| 凸点映射 | Bump Map | die 与封装互连凸点的位置和功能分配 |
| 裸片摆放 | Die Placement | 多 die 封装中各裸片的几何位置规划 |
| 封装规划 | Package Planning | 从系统需求出发规划封装结构、互连、供电、散热和测试 |
